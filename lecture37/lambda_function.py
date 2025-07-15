import boto3

ses = boto3.client('ses')

def lambda_handler(event, context):
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            new_image = record['dynamodb']['NewImage']
            name = new_image['name']['S']
            email = new_image['email']['S']

            response = ses.send_email(
                Source='andy.fil.devops@outlook.com',
                Destination={'ToAddresses': [email]},
                Message={
                    'Subject': {'Data': 'Welcome!'},
                    'Body': {'Text': {'Data': f"Hi {name}, thanks for joining us!"}}
                }
            )
            print(f"Email sent to {email}. ID: {response['MessageId']}")