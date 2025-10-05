from diagrams import Cluster, Diagram, Edge
from diagrams.onprem.client import Users
from diagrams.aws.network import APIGateway, ELB
from diagrams.aws.compute import EKS, Lambda
from diagrams.k8s.network import Ing
from diagrams.k8s.compute import Pod, Deployment
from diagrams.onprem.logging import Fluentbit
from diagrams.aws.management import Cloudwatch


diagram_filename = "architecture"


with Diagram(
    "Max Weather - Architecture",
    filename=diagram_filename,
    show=False,
    direction="TB",
):
    users = Users("Clients")
    api_gw = APIGateway("API Gateway")
    lambda_auth = Lambda("Lambda Authorizer")
    nlb = ELB("NLB")

    with Cluster("EKS"):
        ingress = Ing("ingress-nginx")
        deploy = Deployment("Weather API")
        svc = Pod("Service")
        deploy >> svc
        svc << ingress

    fb = Fluentbit("Fluent Bit")
    cw = Cloudwatch("CloudWatch")

    # Steps per docs
    users >> Edge(label="1) API key + Authorization") >> api_gw
    api_gw >> Edge(label="2) AuthZ via Lambda Authorizer") << lambda_auth
    api_gw >> Edge(label="3) Proxy") >> nlb >> ingress >> svc >> deploy
    deploy >> Edge(label="5) Logs") >> fb >> cw


