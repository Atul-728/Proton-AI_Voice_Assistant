from dotenv import load_dotenv
from livekit import agents
from livekit.agents import AgentSession, Agent, RoomInputOptions, ChatContext, ChatMessage
from livekit.plugins import google, noise_cancellation

# Import your custom modules
from proton_prompts import instructions_prompt, Reply_prompts
from memory_loop import MemoryExtractor
from proton_reasoning import thinking_capability
from proton_google_search import get_current_datetime
from proton_get_whether import get_current_city
load_dotenv()


class Assistant(Agent):
    def __init__(self, chat_ctx, instructions) -> None:
        super().__init__(
            chat_ctx=chat_ctx,
            instructions=instructions,
            llm=google.beta.realtime.RealtimeModel(voice="Charon"),
            tools=[thinking_capability]
        )

async def entrypoint(ctx: agents.JobContext):

    current_datetime = await get_current_datetime.ainvoke("")   # await the coroutine
    city = await get_current_city()                   # await the coroutine

    instructions = instructions_prompt.format(
        current_datetime=current_datetime,
        city=city
    )

    session = AgentSession(
        preemptive_generation=True
    )
    
    #getting the current memory chat
    current_ctx = session.history.items
    

    await session.start(
        room=ctx.room,
        agent=Assistant(chat_ctx=current_ctx, instructions=instructions), #sending currenet chat to llm in realtime
        room_input_options=RoomInputOptions(
            noise_cancellation=noise_cancellation.BVC()
        ),
    )
    await session.generate_reply(
        instructions=Reply_prompts
    )
    conv_ctx = MemoryExtractor()
    await conv_ctx.run(current_ctx)
    


if __name__ == "__main__":
    agents.cli.run_app(agents.WorkerOptions(entrypoint_fnc=entrypoint))