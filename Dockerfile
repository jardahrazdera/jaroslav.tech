# File: Dockerfile
# A radically simplified, single-stage version for maximum reliability.

FROM python:3.11-slim-bullseye

# Set environment variables to prevent Python from writing .pyc files and buffering output
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies (like postgresql-client) and Poetry in one go
RUN apt-get update \
    && apt-get install -y --no-install-recommends postgresql-client \
    && pip install poetry \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Configure Poetry to create the virtual environment inside the project directory (.venv)
RUN poetry config virtualenvs.in-project true

# Copy all project files from your local machine into the container's working directory
COPY . .

# Install Python dependencies using the poetry.lock file.
# This command will create the /app/.venv directory with all packages.
RUN poetry install --only main --no-interaction --no-ansi --no-root

# Expose the port the application runs on
EXPOSE 8000

# Define the command to run when the container starts, using the ABSOLUTE PATH to the executable
CMD ["/app/.venv/bin/gunicorn", "project.wsgi:application", "--bind", "0.0.0.0:8000"]
