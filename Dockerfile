FROM python:3.13-slim

WORKDIR /app

COPY requirements-dev.txt ./
RUN pip install --no-cache-dir --root-user-action=ignore -r requirements-dev.txt

COPY . ./
RUN pip install --no-cache-dir --root-user-action=ignore .

CMD ["devonboarder"]
