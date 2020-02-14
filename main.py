from google.cloud import pubsub_v1
import os


def sub_method(request, context):
    print("I'm the sub mrthod", request)

    import base64

    print("""This Function was triggered by messageId {} published at {}
    """.format(context.event_id, context.timestamp))

    if 'data' in request:
        name = base64.b64decode(request['data']).decode('utf-8')


def pub_method(request):
    print("I'm the sub mrthod", request)

    topic = os.environ["TOPIC"]
    project = os.environ["GCLOUD_PROJECT"]

    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project, topic)
    publisher.publish(topic_path, data="Hello World")

