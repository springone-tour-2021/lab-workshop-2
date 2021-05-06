# Temporary Sandbox Area...

# Lift & Shift the Color Application to Kubernetes - Step 4

## Configure Config Server
The hard-coding of Config Server's address as `localhost:8888` can be found in each application's `application.properties` file.
Take a look, for example, at the bluegreenservice properties file.
```editor:select-matching-text
file: ~/color-app/blueorgreenservice/src/main/resources/application.yml
text: localhost:8888
```

To ensure that local deployments still work smoothly, you can parameterize this value and set `localhost:8888` as the default value.

Update the address of the Config Server in each application.properties file.
```execute-1
for i in */src/main/resources/application.yml; do \
    yq eval \
        '.spring.config.import = "optional:configserver:${CONFIG_SERVER_URI}"' \
        -i $i; \
done
```

## Configure Eureka lookup

The hard-coding of Eureka's address as `localhost:8761` can be found in each application's `application.properties` file.
Take a look, for example, at the bluegreenservice properties file.
```editor:select-matching-text
file: ~/color-app/blueorgreenservice/src/main/resources/application.yml
text: defaultZone: http://localhost:8761/eureka/
```

To ensure that local deployments still work smoothly, you can parameterize this value and set `localhost:8761` as the default value.

Update the address of the Eureka server in each application.properties file.
```execute-1
for i in */src/main/resources/application.yml; do \
    yq eval \
        '.eureka.client.serviceUrl.defaultZone = "http://${EUREKA_HOST:-localhost}:8761/eureka/"' \
        -i $i; \
done
```

For the Kubernetes deployment, `EUREKA_HOST` must be the name of the eureka service.
You can look up this value in the `eureka-service.yaml`.
```editor:select-matching-text
file: ~/color-app/k8s/lift-and-shift/eureka-service.yaml
text: name: eureka
```

Finally, add the `EUREKA_HOST` environment variable to each deployment manifest and set the value appropriately.
```execute-1
for i in k8s/lift-and-shift/*-deployment.yaml; do \
    yq eval \
        '.spec.template.spec.containers[0].env[0].key = "EUREKA_HOST"' \
        -i $i; \
    yq eval \
        '.spec.template.spec.containers[0].env[0].value = "eureka"' \
        -i $i; \
done
```

## Configure Eureka registration

The Auth Gateway and the Routing Gateway also need to connect to the Color Application apps.
They should do so using the K8s services, so you need to make sure each app registers itself in Eureka using its service name, not localhost or an IP address.
This way, when the gateways retrieve the instance address from Eureka, they will get the service name.

Once again, as you make this change, parameterize the property in the application properties file and set the default value to preserve back-compatibility with local deployments.

Update the `application.yml` files.
```execute-1
for i in */src/main/resources/application.yml; do \
    yq eval \
        '.eureka.instance.hostname = "${INSTANCE_HOST:-localhost}"' \
        -i $i; \
done
```

Set the env var in each deployment manifest.
```execute-1
cd k8s 

for i in *-deployment.yaml; do \

    # Get the prefix of each filename since this matches the service name
    value=${i%-deployment.yaml}

    yq eval \
        '.spec.template.spec.containers[0].env[1].key = "INSTANCE_HOST"' \
        -i $i; \

    yq eval \
        ".spec.template.spec.containers[0].env[1].value = \"$value\"" \
        -i $i; \
done

cd ..
```

The last step in the lift & shift exercise is to set the SPRING_PROFILES_ACTIVE value for each instance of blueorgreenservice.

## Configure Spring Boot profiles in deployment manifests

Run the following command to set the profile value in the deployment manifest.
```execute-1
array=( blue green slowgreen yellow )
for i in "${array[@]}"
do
    yq eval \
        '.spec.template.spec.containers[0].env[3].key = "SPRING_PROFILES_ACTIVE"' \
        -i k8s/lift-and-shift/$i-deployment.yaml;
    
    yq eval \
        ".spec.template.spec.containers[0].env[3].value = \"$i\"" \
        -i k8s/lift-and-shift/$i-deployment.yaml;
done
```

## Deploy and test (WIP)

At this point, you can deploy the Color Application to Kubernetes.

Apply all of the yaml files to the cluster.
```execute-1
kubectl apply k8s/lift-and-shift/*
```

Run the following command to watch the status of the pods.
Once all are `running`, type `Ctrl+C` to stop the `wait` command.
```execute-1

### need to port-forward to the auth gateway ??

### if port-forward, localhost:8080 dashboard used in local deployment should work

### can also test with http providing creds at CLI
```

## Add an Ingress & ingress controller?


# Refactor the Color Application for Kubernetes - Step 1

In the next set of exercises, you will refactor the Color Application in order to leverage native Kubernetes functionality.
You will eliminate Eureka and the Routing Gateway from the application architecture.

## Deployment and Service Manifests
Copy the manifests for all apps except Eureka and the Routing Gateway to a new directory.
```
mkdir k8s/refactor
cp k8s/lift-and-shift/* k8s/refactor/

rm k8s/refactor/eureka-deployment.yaml
rm k8s/refactor/eureka-service.yaml
rm k8s/refactor/gateway-deployment.yaml
rm k8s/refactor/gateway-service.yaml
```

## Configure Routing

Rather than control routing through the Routing Gateway, you will use an ingress controller.
There are a variety of ingress controllers available in the Kubernetes ecosystem.
One called [Contour](https://projectcontour.io/) has been pre-installed in your workshop cluster, and an external load balancer has been pre-configured for you to route external traffic into the cluster.
You need to add the specific routing logic pertaining to the Color Application.

You can see the list of resources that Contour adds to Kubernetes by running the following command.
```execute-1
kubectl api-resources | grep -i contour
```

With Contour, you use the `HTTPProxy` resource to define routing rules.
You need to define routing rules to replace the routes currently defined in Java in the Routing Gateway.

Review the business logic defined in the Routing Gateway application.
```editor:select-matching-text
file: ~/color-app/blueorgreengateway/src/main/java/org/springframework/demo/blueorgreengateway/BlueorgreengatewayApplication.java
text: public RouteLocator routeLocator(RouteLocatorBuilder builder) {
```

Create a new manifest file for the HTTPProxy resource definition.
```execute-1
mkdir -p ~/color-app/k8s/refactor
touch ~/color-app/k8s/refactor/httpproxy.yaml
```

Copy the following configuration to the new manifest file.
Notice that it matches the existing Java definitions and that it uses the service names defined in the yaml files you just copied from the lift-and-shift exercise.
```editor:insert-lines-before-line
file: ~/color-app/k8s/refactor/httpproxy.yaml
line: 1
text: |
    apiVersion: projectcontour.io/v1
    kind: HTTPProxy
    metadata:
      name: color-app
    spec:
      virtualhost:
        fqdn: color-app.bar.com
      routes:
        - conditions: 
          - prefix: /blueorgreen
          services:
            - name: blue
              port: 8080
            - name: green
              port: 8080
            - name: slowgreen
              port: 8080
            - name: yellow
              port: 8080
        - conditions:
          - prefix: /
          services:
            - name: frontend
              port: 8080
        - conditions:
          - prefix: /js
          services:
            - name: frontend
              port: 8080
        - conditions:
          - prefix: /color
          services:
            - name: frontend
              port: 8080
```

Add the following configuration to the same manifest for the login/logout routes:
```editor:insert-lines-after-line
file: ~/color-app/k8s/refactor/httpproxy.yaml
line: 29
text: |
        - conditions:
          - prefix: /login
          services:
            - name: authgateway
              port: 8080
        - conditions:
          - prefix: /logout
          services:
            - name: authgateway
              port: 8080
```

#### TODO: premium



# Refactor the Color Application for Kubernetes using Service Mesh - Step 1

In the next set of exercises, you will refactor the Color Application in order to leverage native Kubernetes functionality.
You will be leveraging a service mesh, in this case Istio, to replace some of the application functionality.

## Install Istio

Start by setting a couple of environment variables to facilitate some of the instructions you will be running.
```execute-1
export BG_NS=blueorgreen-istio
export INGRESS_DOMAIN=blueorgreen.springone.coraiberkleid.xyz
```

Download the Istio release file and add the `istioctl` CLI to your PATH.
```execute-1
ISTIO_VERSION=1.9.2
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION TARGET_ARCH=x86_64 sh -
cd istio-$ISTIO_VERSION
export PATH=$PWD/bin:$PATH
```

Install Istio using the `demo` profile which configures sensible defaults for testing.
```execute-1
istioctl install --set profile=demo -y
```

Create the namespace to deploy the Color Application and add a label to it to instruct Istio to automatically inject Envoy sidecar proxies to any apps deployed to this namespace.
```execute-1
kubectl create ns $BG_NS
kubectl label namespace $BG_NS istio-injection=enabled
```

## Configure


## Sandbox

# Install bluegreen demo

# Deploy the app...
kubectl -n $BG_NS apply -f yaml/istio/
# Ensure that there are no issues with the configuration
istioctl analyze -n $BG_NS


# Get Istio Ingress Host
echo "istio-ingressgateway hostname:"
kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# More:
https://istio.io/latest/docs/setup/getting-started/#download









The original flow for a given request is:

End User (first request) --> Auth Gateway* --> Routing Gateway* --> Frontend
End User (subsequent requests) --> Auth Gateway* --> Routing Gateway* --> Color Service

where each * represents a Eureka lookup.

The new flow for a given request will be:

End User (first request) --> Auth Gateway --> Frontend
End User (subsequent requests) --> Auth Gateway --> Color Service

## Service discovery & load balancing

In Kubernetes, each Pod is fronted by a Service resource.
You already created a Service for each app in the previous exercise.
List them using the following command.
```execute-1
kubectl get services
```

Any app that wishes to send requests to a given Pod can simply send the request to the Service.
The Service will load balance all requests across the instances of the corresponding Pod.

In other words, by using the Kubernetes service directly, you no longer need to use Eureka or Ribbon (Ribbon is the client-side library that load balances requests across the endpoints retrieved from Eureka) to locate the Pod instances and load balance requests across them.

## Eureka & Ribbon configuration

You can eliminate Eureka altogether by simply not deploying the `eureka` app.

However, merely doing that will cause errors in the remaining applications, since each app will currently try to register itself iwth Eureka and retrieve the existing registry.
Therefore, you need to disable Eureka registration & fetch in each app.

In addition, the Auth Gateway and Frontend apps act as clients, sending requests to other apps.
This means they use the Ribbon library in conjunction with Eureka.
For these two apps, you also need to disable intagration with Eureka.
Instead, you can enable HTTP support.

You can add all of these configuration parameters into a new istio-specific application config file for each app.
Start by adding a new and empty configuration file to each app.
```execute-1
touch ~/color-app/authgateway/src/main/resources/application-istio.yml
touch ~/color-app/blueorgreenfrontend/src/main/resources/application-istio.yml
touch ~/color-app/blueorgreenservice/src/main/resources/application-istio.yml
```

For Auth Gateway and Frontend, disable Eureka and enable HTTP support for Ribbon.
```editor:insert-lines-before-line
file: ~/color-app/authgateway/src/main/resources/application-istio.yml
line: 1
text: |
    Eureka.client:
      register-with-eureka: false
      fetch-registry: false
      enabled: false

    Ribbon: 
      eureka.enabled: false 
      http.client.enabled: true 

```

For the Frontend, it is also necessary to set Read and Connect timeout settings (** WHY???? **)
```editor:insert-lines-before-line
file: ~/color-app/blueorgreenfrontend/src/main/resources/application-istio.yml
line: 1
text: |
    Eureka.client:
      register-with-eureka: false
      fetch-registry: false
      enabled: false

    Ribbon: 
      eureka.enabled: false 
      http.client.enabled: true 

    ReadTimeout: 10000
    ConnectTimeout: 7000

```

For the color app, you only need to disable Eureka registration and fetch, since this app is not a client to any other and will not send any requests.
```editor:insert-lines-before-line
file: ~/color-app/blueorgreenservice/src/main/resources/application-istio.yml
line: 1
text: |
    Eureka.client:
      register-with-eureka: false
      fetch-registry: false

```

## Route to K8s Service names

Now that the Auth Gateway and the Fronted will not be using Eureka to find their respective target apps, you need to provide the service name directly.
Rather than hard-coding the Kubernetes service name into the application config, use an environment variable to parameterize this setting.
You will later set the value of this variable elsewhere, outside of the compiled application jar.

```editor:insert-lines-after-line
file: ~/color-app/authgateway/src/main/resources/application-istio.yml
line: 9
text: |
    colorApplicationUrl: ${COLOR_APPLICATION_URL}
    
```

```editor:insert-lines-after-line
file: ~/color-app/blueorgreenfrontend/src/main/resources/application-istio.yml
line: 12
text: |
    colorServiceUrl: ${COLOR_SERVICE_URL}
    
```



Future section headers:
# Refactor the Color Application to Integrate More Natively with Kubernetes - Steps 1...N
# Replatform an RSocket-base Application to Kubernetes
# Other...

See https://docs.google.com/document/d/1H5HX9cspvT8_vvsPjEORibedxUrnoqAxZ5IP7_8X1Uc

Notes area:

hostname=$(http -b :8761/eureka/apps | grep instanceId | head -1 | sed 's/.*<instanceId>\(.*\):blueorgreen.*/\1/')

http -b :8761/eureka/apps/blueorgreen/



## SANDBOX: Configure the Ingress

From the Kubernetes docs:

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. 
Traffic routing is controlled by rules defined on the Ingress resource.

An Ingress may be configured to give Services externally-reachable URLs, load balance traffic, terminate SSL/TLS, and offer name-based virtual hosting. 
An Ingress controller is responsible for fulfilling the Ingress, usually with a load balancer, though it may also configure your edge router or additional frontends to help handle the traffic.

An Ingress does not expose arbitrary ports or protocols. 
Exposing services other than HTTP and HTTPS to the internet typically uses a service of type Service.Type=NodePort or Service.Type=LoadBalancer.

[Reference](https://kubernetes.io/docs/concepts/services-networking/ingress/)

# SANDBOX: nginx

In this example, you will use the [nginx ingress controller](https://github.com/kubernetes/ingress-nginx/blob/master/README.md#readme)

Install nginx ingress controller.
```execute-
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.45.0/deploy/static/provider/aws/deploy.yaml
```
OR:
```
https://raw.githubusercontent.com/kubernetes/ingress-nginx/ingress-nginx-3.15.2/deploy/static/provider/aws/deploy.yaml
```