AWSTemplateFormatVersion: "2010-09-09"
Description: "$NAME$"
Resources:
  $NAME$Role:
    Type: "AWS::IAM::Role"
    Properties:
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          -
            Effect: "Allow"
            Principal:
              Service:
                - "ec2.amazonaws.com"
            Action:
              - "sts:AssumeRole"
  $NAME$InstanceProfile:
    Type: "AWS::IAM::InstanceProfile"
    DependsOn: $NAME$Role
    Properties:
      InstanceProfileName: "$NAME$-instance-profile"
      Roles:
        -
          Ref: $NAME$Role
  $NAME$CodePipelineAccess:
    Type: "AWS::IAM::Policy"
    DependsOn: $NAME$Role
    Properties:
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          -
            Effect: "Allow"
            Action:
              - "s3:GetBucketAcl"
              - "s3:GetBucketCORS"
              - "s3:GetBucketLocation"
              - "s3:GetBucketLogging"
              - "s3:GetBucketNotification"
              - "s3:GetBucketPolicy"
              - "s3:GetBucketRequestPayment"
              - "s3:GetBucketTagging"
              - "s3:GetBucketVersioning"
              - "s3:GetBucketWebsite"
              - "s3:GetLifecycleConfiguration"
              - "s3:GetObject"
              - "s3:GetObjectAcl"
              - "s3:GetObjectTagging"
              - "s3:GetObjectTorrent"
              - "s3:GetObjectVersion"
              - "s3:GetObjectVersionAcl"
              - "s3:GetObjectVersionTagging"
              - "s3:GetObjectVersionTorrent"
              - "s3:GetReplicationConfiguration"
              - "s3:ListAllMyBuckets"
              - "s3:ListBucket"
              - "s3:ListBucketMultipartUploads"
              - "s3:ListBucketVersions"
              - "s3:ListMultipartUploadParts"
            Resource: "arn:aws:s3:::codepipeline*"
      PolicyName: $NAME$-read-codepipeline
      Roles:
        -
          Ref: $NAME$Role
  $NAME$ECRLogin:
    Type: "AWS::IAM::Policy"
    DependsOn: $NAME$Role
    Properties:
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          -
            Effect: "Allow"
            Action:
              - "ecr:GetAuthorizationToken"
            Resource: "*"
      PolicyName: $NAME$-ecr-login
      Roles:
        -
          Ref: $NAME$Role
  $NAME$CredstashRead:
    Type: "AWS::IAM::Policy"
    DependsOn: $NAME$Role
    Properties:
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          -
            Effect: "Allow"
            Action:
              - "dynamodb:GetItem"
              - "dynamodb:Query"
              - "dynamodb:Scan"
            Resource: "arn:aws:dynamodb:*:*:table/credential-store"
      PolicyName: $NAME$-credstash
      Roles:
        -
          Ref: $NAME$Role
  $NAME$TagAccess:
    Type: "AWS::IAM::Policy"
    DependsOn: $NAME$Role
    Properties:
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          -
            Effect: "Allow"
            Action:
              - "ec2:DescribeTags"
            Resource: "*"
      PolicyName: $NAME$-describe-tags
      Roles:
        -
          Ref: $NAME$Role
  $NAME$CodeDeploy:
    Type: "AWS::IAM::Policy"
    DependsOn: $NAME$Role
    Properties:
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          -
            Effect: "Allow"
            Action:
              - "codedeploy:*"
            Resource: "arn:aws:codedeploy:*:*:application:$NAME$-*"
      PolicyName: $NAME$-code-deploy
      Roles:
        -
          Ref: $NAME$Role
Outputs:
    OIDCRoleName:
        Description: "Access proxy generated role name"
        Value: !GetAtt $NAME$Role.Arn
        Export:
            Name: !Sub "${AWS::StackName}-RoleName"
