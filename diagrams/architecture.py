from diagrams import Cluster, Diagram, Edge
from diagrams.aws.network import APIGateway, ELB, VPC
from diagrams.aws.compute import EKS, Lambda
from diagrams.aws.integration import SNS
from diagrams.aws.management import Cloudwatch
from diagrams.onprem.client import Users
from diagrams.onprem.monitoring import Prometheus
from diagrams.k8s.network import Ing
from diagrams.k8s.compute import Pod
from diagrams.k8s.compute import Deployment
from diagrams.k8s.clusterconfig import HPA
from diagrams.onprem.logging import Fluentbit


diagram_filename = "architecture"


with Diagram(
    "Max Weather - System Architecture",
    filename=diagram_filename,
    show=False,
    direction="TB",
):
    users = Users("Clients")

    api_gw = APIGateway("Amazon API Gateway\n(REST, stages)")
    lambda_auth = Lambda("Lambda Authorizer\n(OAuth2/JWT)")

    # Edge / load balancing
    nlb = ELB("AWS NLB\n(ingress-nginx, TLS)")

    with Cluster("Amazon EKS (Private)"):
        ingress = Ing("nginx-ingress controller")
        with Cluster("Weather API"):
            deploy = Deployment("Deployment (3 replicas)")
            svc = Pod("Service")
            hpa = HPA("HPA: CPU/Mem")
            deploy >> svc
            svc >> hpa

        fb = Fluentbit("Fluent Bit\n(logs → CloudWatch)")

    with Cluster("VPC (3 public + 3 private subnets, NAT per AZ)"):
        vpc = VPC("VPC + Endpoints\n(S3/ECR/Logs)")

    cw = Cloudwatch("CloudWatch Logs & Metrics")
    sns = SNS("SNS (alerts)")

    # Flow
    users >> Edge(label="API key + Authorization") >> api_gw
    lambda_auth << Edge(label="JWT/IRSA") >> api_gw
    api_gw >> Edge(label="HTTP proxy (mTLS/TLS)") >> nlb
    nlb >> ingress >> svc >> deploy
    fb >> cw
    cw >> sns
    vpc


