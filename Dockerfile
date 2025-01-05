FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VERSION=1.7.1 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    gcc \
    python3-dev && \
    rm -rf /var/lib/apt/lists/*

# Install poetry
RUN python -m venv ${POETRY_HOME} && \
    ${POETRY_HOME}/bin/pip install poetry==${POETRY_VERSION}

# Add poetry to PATH
ENV PATH="${POETRY_HOME}/bin:${PATH}"

WORKDIR /app

# Copy only dependency files first
COPY pyproject.toml ./

# Delete any existing poetry.lock and generate a new one
RUN rm -f poetry.lock && \
    poetry lock

# Install dependencies in a virtual environment
RUN python -m venv .venv && \
    poetry install --no-root

# Copy project files
COPY . .

# Install the project itself
RUN poetry install

# Set the virtual environment path
ENV PATH="/app/.venv/bin:${PATH}"

CMD ["python", "-m", "src.taskmanager.main"]