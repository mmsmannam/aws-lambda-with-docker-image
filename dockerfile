#FROM public.ecr.aws/lambda/python:3.8

#FROM artifactory.awsmgmt.massmutual.com/docker/python:3.9alpine-v0.1.0
FROM python:3.9alpine-v0.1.0

# Copy function code
COPY app.py ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "app.handler" ]