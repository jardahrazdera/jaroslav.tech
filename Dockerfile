# File: Dockerfile
# FINAL WORKING VERSION

# --- Build Stage ---
FROM python:3.11-slim-bullseye AS builder

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

RUN pip install poetry
WORKDIR /app

COPY pyproject.toml poetry.lock ./

RUN poetry config virtualenvs.in-project true
RUN poetry install --only main --no-interaction --no-ansi --no-root


# --- Final Stage ---
FROM python:3.11-slim-bullseye AS final

RUN apt-get update && apt-get install -y --no-install-recommends postgresql-client && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

RUN addgroup --system app && adduser --system --group app
WORKDIR /home/app

COPY --from=builder /app/.venv ./.venv

COPY . .

# Set the PATH to include the virtual environment's bin directory
# While we set this, we won't rely on it for the CMD for maximum reliability
ENV PATH="/home/app/.venv/bin:$PATH"

RUN chown -R app:app /home/app
USER app

EXPOSE 8000

# --- THIS IS THE CRITICAL FIX ---
# Define the default command using the ABSOLUTE PATH to gunicorn.
# This avoids any ambiguity with the $PATH environment variable.
CMD ["/home/app/.venv/bin/gunicorn", "project.wsgi:application", "--bind", "0.0.0.0:8000"]
