import asyncio

async def get_task():
    pass

async def get_task_data(file_id):
    pass

async def send_task_result(image):
    pass

async def main_loop():
    while True:
        task = await get_task()
        if task == None:
            await asyncio.sleep(5)
            continue

        data = await get_task_data(task['file_id'])
        # do task