# Use official Python slim image
FROM python:3.11-slim
# Set working directory inside container
WORKDIR /app
# Copy dependencies first (Docker cache optimization)
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# Copy application code
COPY app/ .
# Expose port
EXPOSE 5000
# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
CMD curl -f http://localhost:5000/health || exit 1
# Run the app
CMD ["python", "app.py"]