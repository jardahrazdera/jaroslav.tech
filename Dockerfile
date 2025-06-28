# File: Dockerfile
# A truly simplified, single-stage version for maximum reliability.

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

# Copy only the dependency files first to leverage Docker's layer cache
COPY pyproject.toml poetry.lock ./

# Install Python dependencies using the poetry.lock file.
# This command will now correctly create the /app/.venv directory.
RUN poetry install --only main --no-interaction --no-ansi --no-root

# Copy the rest of the application code
COPY . .

# Set the PATH to include the virtual environment's bin directory
# This ensures that executables like 'gunicorn' can be found.
ENV PATH="/app/.venv/bin:$PATH"

# Create a non-root user and change ownership for better security
RUN addgroup --system app && adduser --system --group app
RUN chown -R app:app /app
USER app

# Expose the port the application runs on
EXPOSE 8000

# The command to run when the container starts.
# It can now find 'gunicorn' thanks to the updated PATH.
CMD ["gunicorn", "project.wsgi:application", "--bind", "0.0.0.0:8000"]
