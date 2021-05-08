During this workshop you will move an application comprising 4 Spring Boot apps to Kubernetes, including:

*   Test the app locally to understand its behavior
    * Use Eureka for discovery
    * Use Spring Cloud Config Server for configuration
*   "Lift & shift" the apps to Kubernetes
    * Use Spring Cloud Kubernetes for discovery
    * Use Kubernetes ConfigMaps for configuration
    * Create required Kubernetes resources (deployments, services, configmaps, ingress)
*   Modify Kubernetes deployment
    * Use Kubernetes natively for discovery (remove Spring Cloud Kubernetes)