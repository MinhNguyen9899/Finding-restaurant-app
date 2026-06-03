def success_response(message: str, data=None, pagination=None):
    response = {
        "success": True,
        "message": message,
        "data": data
    }

    if pagination:
        response["pagination"] = pagination

    return response