import asyncio
import aiohttp
from config import api_url
import io
from utils.common_utils import get_image
from PIL import Image
import numpy as np
import inpainting

async def get_task(session: aiohttp.ClientSession):
    async with session.get(f'{api_url}/api/worker/image') as response:
        res = await response.json()
        print('Task response:', res)
        if res is None or res['file_id'] is None:
            return None
        return res

async def load_image(url, session):
    async with session.get(url) as response:
        return await response.read()


async def get_task_data(file_id, session: aiohttp.ClientSession):
    resp_img = load_image(f'{api_url}/api/worker/image/data?type=image&file_id={file_id}', session)
    resp_mask = load_image(f'{api_url}/api/worker/image/data?type=mask&file_id={file_id}', session)
    img_bytes, mask_bytes = await asyncio.gather(resp_img, resp_mask)
    img_pil, img_np = get_image(io.BytesIO(img_bytes))
    mask_pil, mask_np = get_image(io.BytesIO(mask_bytes))
    return {'image': img_np, 'mask': mask_np, 'image_format': img_pil.format}

def to_bytes(image_np, format):
    img = Image.fromarray(image_np)
    img_byte_arr = io.BytesIO()
    img.save(img_byte_arr, format=format)
    return img_byte_arr.getvalue()

async def send_task_result(image, file_id, session: aiohttp.ClientSession):
    data = aiohttp.FormData()
    data.add_field('image',
                image,
                filename='result_nani',
                content_type='image/png') # not correct
    await session.post(f'{api_url}/api/worker/image/{file_id}', data=data)

async def main(loop):
    while True:
        async with aiohttp.ClientSession() as session:
            # get task
            print('Getting task')
            task = await get_task(session=session)
            if task == None:
                # missing task, we need sleep and get new task
                print('Missing task, sleep...')
                await asyncio.sleep(2)
                continue

            print('Getting task data')
            data = await get_task_data(task['file_id'], session=session)
        
        # do task
        print('Do task')
        res = inpainting.remove_watermark(data['image'], data['mask'])
        res = (res * 255).astype(np.uint8)
        res = np.reshape(res, (res.shape[1], res.shape[2], res.shape[0]))
        print('Output shape: ', res.shape)
        res_bytes = to_bytes(res, format=data['image_format'])
        
        async with aiohttp.ClientSession() as out_session:
            print('Send res')
            await send_task_result(res_bytes, task['file_id'], session=out_session)
            print('Task sended')

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main(loop))