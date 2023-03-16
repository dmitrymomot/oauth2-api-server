package main

import (
	"context"
	"database/sql"
	"os"
	"os/signal"
	"syscall"

	"github.com/dmitrymomot/oauth2-api-server/repository"
	"github.com/hibiken/asynq"
	_ "github.com/lib/pq" // init pg driver
	"github.com/sirupsen/logrus"
	"golang.org/x/sync/errgroup"
)

func main() {
	// Init logger
	logrus.SetReportCaller(false)
	logger := logrus.WithFields(logrus.Fields{
		"app":       appName,
		"build_tag": buildTagRuntime,
	})
	if appDebug {
		logger.Logger.SetLevel(logrus.DebugLevel)
	} else {
		logger.Logger.SetLevel(logrus.InfoLevel)
	}

	defer func() { logger.Info("server successfully shutdown") }()

	// Errgroup with context
	eg, ctx := errgroup.WithContext(newCtx(logger))

	// Init DB connection
	db, err := sql.Open("postgres", dbConnString)
	if err != nil {
		logger.WithError(err).Fatal("failed to init db connection")
	}
	defer db.Close()

	db.SetMaxOpenConns(dbMaxOpenConns)
	db.SetMaxIdleConns(dbMaxIdleConns)

	if err := db.Ping(); err != nil {
		logger.WithError(err).Fatal("failed to ping db")
	}

	// Init repository
	repo, err := repository.Prepare(ctx, db)
	if err != nil {
		logger.WithError(err).Fatal("failed to init repository")
	}
	_ = repo // TODO: use repo

	// Redis connect options for asynq client
	redisConnOpt, err := asynq.ParseRedisURI(redisConnString)
	if err != nil {
		logger.WithError(err).Fatal("failed to parse redis connection string")
	}

	// Init asynq client
	asynqClient := asynq.NewClient(redisConnOpt)
	defer asynqClient.Close()

	// Init HTTP router
	r := initRouter(logger)

	// Run HTTP server
	eg.Go(runServer(ctx, httpPort, r, logger))

	// Run asynq worker
	eg.Go(runQueueServer(
		redisConnOpt,
		logger,
		// ... add more workers here
	))

	// Run asynq scheduler
	eg.Go(runScheduler(
		redisConnOpt,
		logger,
		// ... add more schedulers here
	))

	// Run all goroutines
	if err := eg.Wait(); err != nil {
		logger.WithError(err).Fatal("error occurred")
	}
}

// newCtx creates a new context that is cancelled when an interrupt signal is received.
func newCtx(log *logrus.Entry) context.Context {
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		defer cancel()

		sCh := make(chan os.Signal, 1)
		signal.Notify(sCh, syscall.SIGHUP, syscall.SIGINT, syscall.SIGTERM, syscall.SIGQUIT, syscall.SIGUSR1, syscall.SIGUSR2, syscall.SIGPIPE)
		<-sCh

		// Shutdown signal with grace period of N seconds (default: 5 seconds)
		shutdownCtx, shutdownCtxCancel := context.WithTimeout(ctx, httpServerShutdownTimeout)
		defer shutdownCtxCancel()

		<-shutdownCtx.Done()
		if shutdownCtx.Err() == context.DeadlineExceeded {
			log.Error("shutdown timeout exceeded")
		}
	}()
	return ctx
}
