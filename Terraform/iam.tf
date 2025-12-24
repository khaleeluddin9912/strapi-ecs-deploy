# ECS Execution Role - IMPORT or use data
data "aws_iam_role" "ecs_execution" {
  name = "khaleel-ecs-execution-role"
}

# CodeDeploy Service Role - USE DATA BLOCK
data "aws_iam_role" "codedeploy_role" {
  name = "khaleel-codedeploy-role"
}

# Then attach policies to the existing role
resource "aws_iam_role_policy_attachment" "codedeploy_ecs_policy" {
  role       = data.aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}
