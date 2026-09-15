import base64
import json
import mimetypes
from typing import Literal

from fastapi import FastAPI, File, HTTPException, UploadFile
from openai import OpenAI
from pydantic import BaseModel, Field


app = FastAPI(
    title="Hồn Việt AI",
    version="1.1.0",
)

client = OpenAI()


class HeritageContext(BaseModel):
    name: str = ""
    location: str = ""
    confidence: int = 0
    category: str = ""
    introduction: str = ""
    history: str = ""
    architecture_culture: str = ""
    conservation_tips: list[str] = Field(default_factory=list)


class GuideMessage(BaseModel):
    role: Literal["user", "assistant"]
    content: str


class ChatRequest(BaseModel):
    heritage: HeritageContext
    messages: list[GuideMessage]


@app.get("/")
def home():
    return {
        "status": "Hồn Việt AI backend running"
    }


@app.post("/identify")
async def identify_heritage(
    file: UploadFile = File(...)
):
    try:
        image_bytes = await file.read()

        if not image_bytes:
            raise HTTPException(
                status_code=400,
                detail="Ảnh rỗng.",
            )

        if len(image_bytes) > 10 * 1024 * 1024:
            raise HTTPException(
                status_code=400,
                detail="Ảnh quá lớn. Tối đa 10 MB.",
            )

        mime_type = file.content_type

        if (
            not mime_type
            or not mime_type.startswith("image/")
        ):
            guessed_type, _ = mimetypes.guess_type(
                file.filename or ""
            )
            mime_type = guessed_type or "image/jpeg"

        allowed_types = {
            "image/jpeg",
            "image/png",
            "image/webp",
        }

        if mime_type not in allowed_types:
            raise HTTPException(
                status_code=400,
                detail=(
                    "Định dạng ảnh không được hỗ trợ: "
                    f"{mime_type}"
                ),
            )

        image_base64 = base64.b64encode(
            image_bytes
        ).decode("utf-8")

        image_url = (
            f"data:{mime_type};base64,"
            f"{image_base64}"
        )

        response = client.responses.create(
            model="gpt-5.6-luna",
            input=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "input_text",
                            "text": """
Bạn là Hồn Việt AI.

Nhiệm vụ của bạn là phân tích ảnh di sản, địa danh,
công trình lịch sử, văn hóa hoặc kiến trúc tại Việt Nam.

Quy tắc:
1. Chỉ xác định địa danh khi có đủ bằng chứng trực quan.
2. Không được bịa địa danh.
3. Nếu không xác định được thì name phải là "Không xác định".
4. confidence là số nguyên từ 0 đến 100.
5. Trả lời bằng tiếng Việt.
6. Nội dung lịch sử phải ngắn gọn, dễ hiểu với khách du lịch.
7. conservation_tips gồm đúng 4 hướng dẫn du lịch có trách nhiệm.
""",
                        },
                        {
                            "type": "input_image",
                            "image_url": image_url,
                            "detail": "high",
                        },
                    ],
                }
            ],
            text={
                "format": {
                    "type": "json_schema",
                    "name": "heritage_result",
                    "strict": True,
                    "schema": {
                        "type": "object",
                        "properties": {
                            "name": {"type": "string"},
                            "location": {"type": "string"},
                            "confidence": {
                                "type": "integer",
                                "minimum": 0,
                                "maximum": 100,
                            },
                            "category": {"type": "string"},
                            "introduction": {"type": "string"},
                            "history": {"type": "string"},
                            "architecture_culture": {"type": "string"},
                            "conservation_tips": {
                                "type": "array",
                                "items": {"type": "string"},
                                "minItems": 4,
                                "maxItems": 4,
                            },
                        },
                        "required": [
                            "name",
                            "location",
                            "confidence",
                            "category",
                            "introduction",
                            "history",
                            "architecture_culture",
                            "conservation_tips",
                        ],
                        "additionalProperties": False,
                    },
                }
            },
        )

        return json.loads(
            response.output_text
        )

    except HTTPException:
        raise

    except Exception as e:
        print(
            "IDENTIFY ERROR:",
            repr(e),
        )

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )


@app.post("/chat")
def chat_with_guide(request: ChatRequest):
    try:
        heritage = request.heritage

        context = f"""
Địa danh hiện tại:
- Tên: {heritage.name}
- Vị trí: {heritage.location}
- Độ tin cậy AI: {heritage.confidence}%
- Loại: {heritage.category}
- Giới thiệu: {heritage.introduction}
- Lịch sử: {heritage.history}
- Kiến trúc & văn hóa: {heritage.architecture_culture}
- Hướng dẫn bảo tồn: {json.dumps(
    heritage.conservation_tips,
    ensure_ascii=False
)}
"""

        conversation = [
            {
                "role": "developer",
                "content": (
                    "Bạn là AI Travel Guide của Hồn Việt AI. "
                    "Hãy trả lời bằng tiếng Việt, thân thiện, ngắn gọn, "
                    "dễ hiểu cho khách du lịch. "
                    "Ưu tiên thông tin trong bối cảnh địa danh được cung cấp. "
                    "Nếu người dùng hỏi điều không có đủ dữ kiện chắc chắn "
                    "(ví dụ giá vé, giờ mở cửa, sự kiện hoặc quy định hiện tại), "
                    "hãy nói rõ rằng thông tin có thể thay đổi và không được bịa. "
                    "Khi phù hợp, nhắc người dùng tôn trọng di sản và cộng đồng địa phương."
                ),
            },
            {
                "role": "user",
                "content": context,
            },
        ]

        for message in request.messages[-12:]:
            conversation.append(
                {
                    "role": message.role,
                    "content": message.content,
                }
            )

        response = client.responses.create(
            model="gpt-5.6-luna",
            input=conversation,
        )

        answer = response.output_text.strip()

        if not answer:
            raise RuntimeError(
                "AI không trả về nội dung."
            )

        return {
            "answer": answer,
        }

    except Exception as e:
        print(
            "CHAT ERROR:",
            repr(e),
        )

        raise HTTPException(
            status_code=500,
            detail=str(e),
        )


