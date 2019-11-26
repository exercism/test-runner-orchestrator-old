class ContainerRunnerError < RuntimeError
end

class ContainerTimeoutError < ContainerRunnerError
end

class ContainerWorkerUnavailableError < ContainerRunnerError
end

class FailedRequest < ContainerRunnerError
end

