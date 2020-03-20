from flask import Flask
from flask import render_template
from kubernetes import client, config
import os

# Simple keep ui
app = Flask(__name__)


@app.route("/")
def hello():
  try:
    config.load_incluster_config()
  except Exception as exp:
    print('Unable to load_incluster_config(), attempting load_kube_config()')
    print(f'Exception: {exp}')  
    config.load_kube_config()
  
  v1 = client.CoreV1Api()
  crd_api = client.CustomObjectsApi()
  group = "mongodb.com"
  version = "v1"
  plural = "mongodb"
  namespace = os.getenv("NAMESPACE","mongodb")
  pretty = True
  ret = crd_api.list_namespaced_custom_object(group, version, namespace,plural, pretty=pretty, watch=False)
  return render_template('main.html',clusters=ret.get('items'))

if __name__ == "__main__":
    app.run(host='0.0.0.0')
