# File: Dockerfile
# FINAL CORRECTED VERSION FOR POETRY

# --- Build Stage ---
# Use an official Python runtime as a parent image
FROM python:3.11-slim-bullseye AS builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

# Install Poetry
RUN pip install poetry

# Set the working directory
WORKDIR /app

# Copy only the dependency definition files
COPY pyproject.toml poetry.lock ./

# --- THIS IS THE CRITICAL FIX ---
# Configure Poetry to create the virtualenv inside the project directory (.venv)
RUN poetry config virtualenvs.in-project true

# Install only the project dependencies, not the project itself
# Now, Poetry will create the .venv folder in the current directory (/app)
RUN poetry install --only main --no-interaction --no-ansi --no-root


# --- Final Stage ---
# Use a clean Python image for the final image
FROM python:3.11-slim-bullseye AS final

# Install system dependencies, including the PostgreSQL client for dbshell
RUN apt-get update && apt-get install -y --no-install-recommends postgresql-client && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

# Create a non-root user to run the application for better security
RUN addgroup --system app && adduser --system --group app

# Set the working directory
WORKDIR /home/app

# Copy the installed virtual environment from the builder stage
COPY --from=builder /app/.venv ./.venv

# Copy the application code into the container
COPY . .

# Set the PATH to include the virtual environment's bin directory
ENV PATH="/home/app/.venv/bin:$PATH"

# Change ownership of the files to the non-root user
RUN chown -R app:app /home/app

# Switch to the non-root user
USER app

# Expose the port the app runs on
EXPOSE 8000
