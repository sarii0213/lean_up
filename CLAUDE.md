# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Application Overview

LeanUp is a Japanese health tracking Rails application focused on weight management and period tracking with LINE Bot integration. Built with Rails 8, PostgreSQL, and deployed on AWS ECS with cost-optimization features.

## Essential Development Commands

```bash
# Setup and development
bin/setup                         # Complete setup: dependencies, DB, server start
bin/dev                          # Start development server
docker-compose up                # Alternative Docker development environment

# Database management (uses Ridgepole, NOT Rails migrations)
bundle exec rake ridgepole:apply    # Apply schema changes from Schemafile
bundle exec rake ridgepole:diff     # Show schema differences
bundle exec rake ridgepole:export   # Export current schema

# Testing and quality
bundle exec rspec                    # Run test suite
bundle exec rspec spec/path/file_spec.rb  # Run specific test
bundle exec rubocop                 # Code style linting
bundle exec erblint .              # ERB template linting
bin/brakeman --no-pager            # Security vulnerability scan
```

## Key Architecture Patterns

### Database Schema Management
- **Uses Ridgepole instead of Rails migrations** - all schema changes go in `db/Schemafile`
- Schema is automatically applied in test suite and deployment
- Never create Rails migrations - always edit the Schemafile

### Core Models & Relationships
- **User**: Devise authentication + LINE OAuth (provider/uid fields)
- **Record**: Weight tracking with moving average trend analysis
- **Objective**: Vision board goals (image via Active Storage or text, with ordering)
- **Period**: Menstrual cycle tracking with date validation constraints

### Frontend Architecture
- **Hotwire**: Turbo + Stimulus for SPA-like experience without heavy JavaScript
- **ViewComponent**: Component-based view architecture
- **Semantic UI**: CSS framework with custom SCSS partials
- **Importmap**: JavaScript module management (no webpack/bundler)

### Internationalization
- Primary locale is Japanese (`:ja`)
- All user-facing text should use I18n with Japanese translations
- Custom Devise and Kaminari locales are configured

## Technology Stack Specifics

### Background Jobs
- **Solid Queue** (Rails 8 default) for background processing
- LINE notification jobs for user engagement

### Testing Setup
- **RSpec** with FactoryBot for test data generation
- **Capybara + Selenium** for system tests with Chrome driver
- Docker Compose includes Chrome service for testing

### AWS Deployment
- **ECS** with automated RDS start/stop via Lambda (5:00-22:00 JST for cost savings)
- **ECR** for Docker image registry
- RDS Aurora Serverless for PostgreSQL

## Important Development Notes

### Cost Optimization
- RDS automatically stops at 22:00 JST and starts at 5:00 JST daily
- Be aware of this when debugging production issues outside business hours

### Security & Authentication
- LINE OAuth integration requires proper provider/uid handling
- CSP policies are configured - be mindful when adding external resources
- Brakeman security scanning runs in CI

### Component Patterns
- Use ViewComponent for reusable UI elements
- Chart components use Chartkick for data visualization
- Stimulus controllers handle interactive behavior

## File Structure Notes

- `db/Schemafile` - Database schema (NOT db/migrate/)
- `config/locales/` - Japanese translations and Devise customizations
- `app/components/` - ViewComponent classes
- `deploy/` - CloudFormation templates for AWS infrastructure
- `spec/factories/` - FactoryBot test data definitions