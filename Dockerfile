# --- Build Stage ---
FROM python:3.11-slim-bullseye AS builder
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
RUN pip install poetry
WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN poetry install --no-dev --no-interaction --no-ansi

# --- Final Stage ---
FROM python:3.11-slim-bullseye AS final

# Install system dependencies, including the PostgreSQL client for dbshell
RUN apt-get update && apt-get install -y --no-install-recommends postgresql-client && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
RUN addgroup --system app && adduser --system --group app
WORKDIR /home/app
COPY --from=builder /app/.venv ./.venv
COPY manage.py .
COPY project ./project
ENV PATH="/home/app/.venv/bin:$PATH"
RUN chown -R app:app /home/app
USER app
EXPOSE 8000