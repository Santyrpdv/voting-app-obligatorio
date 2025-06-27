import os, boto3, json, datetime

ECR      = boto3.client("ecr")
REPOS    = os.environ["REPOS"].split(",")     # ej. "vote,result,worker"
KEEP_N   = int(os.environ.get("KEEP_N", "10"))

def handler(event, context):
    deleted = {}

    for repo in REPOS:
        paginator = ECR.get_paginator('describe_images')
        all_imgs  = []
        for page in paginator.paginate(repositoryName=repo, filter={'tagStatus':'TAGGED'}):
            all_imgs += page['imageDetails']

        if not all_imgs:
            continue

        all_imgs.sort(key=lambda d: d['imagePushedAt'], reverse=True)

        deletable = [
            {"imageDigest": d["imageDigest"], "imageTag": d["imageTags"][0]}
            for d in all_imgs[KEEP_N:]
        ]

        if deletable:
            ECR.batch_delete_image(repositoryName=repo, imageIds=deletable)
            deleted[repo] = len(deletable)

    print("Deleted:", json.dumps(deleted))
    return {"deleted": deleted, "timestamp": datetime.datetime.utcnow().isoformat()}
