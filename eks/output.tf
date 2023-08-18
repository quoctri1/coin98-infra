

# output "endpoint" {
#   value = aws_eks_cluster.eks.endpoint
# }

output "issuer" {
  value = aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

