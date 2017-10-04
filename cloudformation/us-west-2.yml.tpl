AWSTemplateFormatVersion: "2010-09-09"
Description: "$NAME$"
Mappings:
  dev:
      us-west-2:
        AMI: ami-5bc13c23
        CertificateARN: "arn:aws:acm:us-west-2:656532927350:certificate/93b81548-c28d-4912-b621-fc6cc6b52274"
  prod:
      us-west-2:
        AMI: ami-5bc13c23
        CertificateARN: ""
Parameters:
  SSHKeyName:
    Description: Name of the existing ssh key that should have access
    Type: String
    MinLength: "1"
    Default: akrug-key
  EnvType:
    Description: Environment type.
    Default: dev
    Type: String
    AllowedValues:
      - prod
      - dev
Conditions:
  UseProdCondition:
    !Equals [!Ref EnvType, prod]
  UseDevCondition:
    !Equals [!Ref EnvType, dev]
Resources:
  $NAME$InternetGateway:
    Type: "AWS::EC2::InternetGateway"
    Properties:
      Tags:
        - Key: Name
          Value: $NAME$
  $NAME$VPC:
    Type: "AWS::EC2::VPC"
    DependsOn: $NAME$InternetGateway
    Properties:
      CidrBlock: "10.0.0.0/16"
      EnableDnsSupport: True
      EnableDnsHostnames: True
      Tags:
        - Key: Name
          Value: $NAME$
  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    DependsOn: $NAME$VPC
    Properties:
      VpcId:
        Ref: $NAME$VPC
      InternetGatewayId:
        Ref: $NAME$InternetGateway
  $NAME$RouteTable:
    Type: "AWS::EC2::RouteTable"
    DependsOn: [ $NAME$VPC, $NAME$InternetGateway, AttachGateway ]
    Properties:
      VpcId:
        Ref: $NAME$VPC
      Tags:
        - Key: Name
          Value: $NAME$
  $NAME$DefaultRoute:
    Type: AWS::EC2::Route
    DependsOn: $NAME$InternetGateway
    Properties:
      RouteTableId:
        Ref: $NAME$RouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId:
        Ref: $NAME$InternetGateway
  $NAME$Subnet1:
    Type: "AWS::EC2::Subnet"
    DependsOn: $NAME$RouteTable
    Properties:
      AvailabilityZone: "us-west-2a"
      CidrBlock: "10.0.0.0/24"
      MapPublicIpOnLaunch: True
      VpcId:
        Ref: $NAME$VPC
      Tags:
        - Key: Name
          Value: $NAME$ Subnet 1
  $NAME$Subnet2:
    Type: "AWS::EC2::Subnet"
    DependsOn: $NAME$RouteTable
    Properties:
      AvailabilityZone: "us-west-2b"
      CidrBlock: "10.0.1.0/24"
      MapPublicIpOnLaunch: True
      VpcId:
        Ref: $NAME$VPC
      Tags:
        - Key: Name
          Value: $NAME$ Subnet 2
  $NAME$Subnet3:
    Type: "AWS::EC2::Subnet"
    DependsOn: $NAME$RouteTable
    Properties:
      AvailabilityZone: "us-west-2c"
      CidrBlock: "10.0.2.0/24"
      MapPublicIpOnLaunch: True
      VpcId:
        Ref: $NAME$VPC
      Tags:
        - Key: Name
          Value: $NAME$ Subnet 3
  $NAME$RouteAssoc1:
    Type: "AWS::EC2::SubnetRouteTableAssociation"
    DependsOn: $NAME$DefaultRoute
    Properties:
      RouteTableId:
        Ref: $NAME$RouteTable
      SubnetId:
        Ref: $NAME$Subnet1
  $NAME$RouteAssoc2:
    Type: "AWS::EC2::SubnetRouteTableAssociation"
    DependsOn: $NAME$DefaultRoute
    Properties:
      RouteTableId:
        Ref: $NAME$RouteTable
      SubnetId:
        Ref: $NAME$Subnet2
  $NAME$RouteAssoc3:
    Type: "AWS::EC2::SubnetRouteTableAssociation"
    DependsOn: $NAME$DefaultRoute
    Properties:
      RouteTableId:
        Ref: $NAME$RouteTable
      SubnetId:
        Ref: $NAME$Subnet3
  $NAME$SecGroup:
    Type: "AWS::EC2::SecurityGroup"
    DependsOn: $NAME$VPC
    Properties:
      GroupDescription: "Allows ports to web instances of $NAME$ from ELB."
      VpcId:
        Ref: $NAME$VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: '80'
          ToPort: '80'
          CidrIp: 10.0.0.0/8
        - IpProtocol: tcp
          FromPort: '22'
          ToPort: '22'
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: $NAME$
  $NAME$ELBSecGroup:
    Type: "AWS::EC2::SecurityGroup"
    DependsOn: $NAME$VPC
    Properties:
      GroupDescription: "Allows access to the ELB listeners."
      VpcId:
        Ref: $NAME$VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: '443'
          ToPort: '443'
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: '80'
          ToPort: '80'
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: '22'
          ToPort: '22'
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: $NAME$ ELB
  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    DependsOn: $NAME$ELBSecGroup
    Properties:
      Scheme: internet-facing
      Subnets:
        - Ref: $NAME$Subnet1
        - Ref: $NAME$Subnet2
        - Ref: $NAME$Subnet3
      SecurityGroups:
        - Ref: $NAME$ELBSecGroup
      Tags:
        - Key: Name
          Value: $NAME$
  ALBHTTPListener:
    Type : AWS::ElasticLoadBalancingV2::Listener
    DependsOn: ApplicationLoadBalancer
    Properties:
      DefaultActions:
      - Type: forward
        TargetGroupArn:
          Ref: ALBTargetGroup
      LoadBalancerArn:
        Ref: ApplicationLoadBalancer
      Port: 80
      Protocol: HTTP
  ALBHTTPSListener:
    Type : AWS::ElasticLoadBalancingV2::Listener
    DependsOn: ApplicationLoadBalancer
    Properties:
      Certificates:
        - CertificateArn: !FindInMap [!Ref EnvType, !Ref "AWS::Region", CertificateARN]
      DefaultActions:
      - Type: forward
        TargetGroupArn:
          Ref: ALBTargetGroup
      LoadBalancerArn:
        Ref: ApplicationLoadBalancer
      Port: 443
      Protocol: HTTPS
      SslPolicy: ELBSecurityPolicy-2016-08
  ALBTargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    DependsOn: ApplicationLoadBalancer
    Properties:
      HealthyThresholdCount: 2
      HealthCheckIntervalSeconds: 10
      UnhealthyThresholdCount: 2
      HealthCheckPath: /health
      HealthCheckPort: 80
      Name: $NAME$HTTPs
      Port: 80
      Protocol: HTTP
      VpcId:
        Ref: $NAME$VPC
      Tags:
        - Key: Name
          Value: $NAME$
  ALBTargetGroup1:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
    DependsOn: ApplicationLoadBalancer
    Properties:
      HealthyThresholdCount: 2
      HealthCheckIntervalSeconds: 10
      UnhealthyThresholdCount: 2
      HealthCheckPath: /health
      HealthCheckPort: 80
      Name: $NAME$HTTP
      Port: 80
      Protocol: HTTP
      VpcId:
        Ref: $NAME$VPC
      Tags:
        - Key: Name
          Value: $NAME$
  $NAME$LaunchConfigProd:
    Type: "AWS::AutoScaling::LaunchConfiguration"
    Condition: UseProdCondition
    Properties:
      KeyName: !Ref SSHKeyName
      ImageId: !FindInMap [!Ref EnvType, !Ref "AWS::Region", AMI]
      IamInstanceProfile: "$NAME$-instance-profile"
      UserData:
        Fn::Base64: !Sub |
          #cloud-config
          repo_update: true
          repo_upgrade: all
          runcmd:
            - REGION=$(curl 169.254.169.254/latest/meta-data/placement/availability-zone/ | sed 's/[a-z]$//')
            - yum update -y
            - yum install ruby wget make -y
            - cd /home/ec2-user
            - pip install boto3 --upgrade
            - wget https://aws-codedeploy-$REGION.s3.amazonaws.com/latest/install
            - chmod +x ./install
            - ./install auto
            - aws ecr get-login --region us-west-2 | bash
            - docker run -d -e SQS_QUEUE=$NAME$-fluentd-sqs -v /var/log:/var/log 656532927350.dkr.ecr.us-west-2.amazonaws.com/sqs-fluentd:latest td-agent -c /etc/td-agent/td-agent.conf
            - mkdir /home/ec2-user/app
            - cd /home/ec2-user/app
            - git clone $GIT_URL$ git
            - git checkout production
            - cd /home/ec2-user/app/git/
            - make compose-production
      SecurityGroups:
        - Ref: $NAME$SecGroup
      InstanceType: "t2.medium"
  $NAME$LaunchConfigDev:
    Type: "AWS::AutoScaling::LaunchConfiguration"
    Condition: UseDevCondition
    DependsOn: [ $NAME$Subnet1, $NAME$Subnet2, $NAME$Subnet3 ]
    Properties:
      KeyName: !Ref SSHKeyName
      ImageId: !FindInMap [!Ref EnvType, !Ref "AWS::Region", AMI]
      IamInstanceProfile: "$NAME$-instance-profile"
      UserData:
        Fn::Base64: !Sub |
          #cloud-config
          repo_update: true
          repo_upgrade: all
          runcmd:
            - REGION=$(curl 169.254.169.254/latest/meta-data/placement/availability-zone/ | sed 's/[a-z]$//')
            - yum update -y
            - yum install ruby wget make -y
            - cd /home/ec2-user
            - pip install boto3 --upgrade
            - wget https://aws-codedeploy-$REGION.s3.amazonaws.com/latest/install
            - chmod +x ./install
            - ./install auto
            - aws ecr get-login --region us-west-2 | bash
            - docker run -d -e SQS_QUEUE=$NAME$-fluentd-sqs -v /var/log:/var/log 656532927350.dkr.ecr.us-west-2.amazonaws.com/sqs-fluentd:latest td-agent -c /etc/td-agent/td-agent.conf
            - mkdir /home/ec2-user/app
            - cd /home/ec2-user/app
            - git clone $GIT_URL$ git
            - cd /home/ec2-user/app/git
            - make compose-staging
      SecurityGroups:
        - Ref: $NAME$SecGroup
      InstanceType: "t2.medium"
  HTTPsListenerRule:
    Type: AWS::ElasticLoadBalancingV2::ListenerRule
    Properties:
      Actions:
      - Type: forward
        TargetGroupArn:
          Ref: ALBTargetGroup1
      Conditions:
      - Field: path-pattern
        Values:
        - "*"
      ListenerArn:
        Ref: ALBHTTPSListener
      Priority: 1
  HTTPListenerRule:
    Type: AWS::ElasticLoadBalancingV2::ListenerRule
    Properties:
      Actions:
      - Type: forward
        TargetGroupArn:
          Ref: ALBTargetGroup1
      Conditions:
      - Field: path-pattern
        Values:
        - "*"
      ListenerArn:
        Ref: ALBHTTPListener
      Priority: 1
  $NAME$ASG:
    Type: "AWS::AutoScaling::AutoScalingGroup"
    DependsOn: [ $NAME$Subnet1, $NAME$Subnet2, $NAME$Subnet3 ]
    Properties:
      Tags:
        -
          Key: Application
          Value: $NAME$
          PropagateAtLaunch: true
        -
          Key: Name
          Value: $NAME$-Worker
          PropagateAtLaunch: true
      TargetGroupARNs:
         - Ref: ALBTargetGroup
         - Ref: ALBTargetGroup1
      MaxSize: "5"
      MinSize: "3"
      VPCZoneIdentifier:
        - Ref: $NAME$Subnet1
        - Ref: $NAME$Subnet2
        - Ref: $NAME$Subnet3
      LaunchConfigurationName:
        !If [UseProdCondition, Ref: $NAME$LaunchConfigProd, Ref: $NAME$LaunchConfigDev]
