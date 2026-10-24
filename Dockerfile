# Imagem de testes do TaskAnalyzer (Bootcamp III, Fase 3).
# Base leve na versao minima do contrato (CONTEXT_RULES 1.1): Python 3.11.
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Dependencias primeiro, para aproveitar o cache de camadas entre builds.
COPY requirements.txt .
RUN pip install -r requirements.txt

# Apenas o que a suite precisa: o modulo e o harness.
COPY src/ src/
COPY tests/ tests/

# A suite roda como usuario sem privilegios.
RUN useradd --create-home --shell /usr/sbin/nologin analyzer \
    && chown -R analyzer:analyzer /app
USER analyzer

# Comando de entrada: a suite inteira, em modo verboso.
CMD ["pytest", "tests/test_harness.py", "-v"]
