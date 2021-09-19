#####################
#                   #
# KINESIS FIREHOUSE #
#                   #
#####################

resource "aws_iam_policy" "firehose" {
  name        = "stockprices_stream_role"
  path        = "/"
  description = ""

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource":"*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "glue:*"
            ],
            "Resource":"*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource":"*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "firehose:*"
            ],
            "Resource":"*"
        },
        {
            "Effect": "Allow",
            "Action": [
               "redshift:*"
            ],
            "Resource":"*"
        },
        {
            "Effect": "Allow",
            "Action": [
               "es:*"
            ],
            "Resource":"*"
        },
        {
            "Effect": "Allow",
            "Action": [
               "ec2:*"
            ],
            "Resource":"*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "firehose_role" {
  name = "stockprices_stream_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose_attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose.arn
}

#####################
#                   #
#    GLUE CRAWLER   #
#                   #
#####################

resource "aws_iam_policy" "glue_policy" {
  name        = "stockprices_glue_policy"
  path        = "/"
  description = "Policy for AWS Glue service role which allows access to related services including EC2, S3, and Cloudwatch Logs"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "glue:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "glue_role" {
  name = "stockprices_glue_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "glue_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}