data "aws_iam_role" "ecs_execution" {
  name = "khaleel-ecs-execution-role"
}

data "aws_iam_role" "codedeploy_role" {
  name = "khaleel-codedeploy-role"
}

resource "aws_iam_role_policy_attachment" "codedeploy_ecs_policy" {
  role       = data.aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}