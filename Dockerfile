FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends git bash \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt requirements.txt
COPY requirements-dbt.txt requirements-dbt.txt

RUN python -m pip install --upgrade pip \
    && pip install -r requirements.txt \
    && pip install -r requirements-dbt.txt

COPY . .

CMD ["bash"]