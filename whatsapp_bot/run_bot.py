"""
Main entry point for WhatsApp Bot
Runs both Node.js server (WhatsApp Web) and Python message handler
"""
import asyncio
import logging
import subprocess
import sys
import signal
from pathlib import Path
from aiohttp import web

from message_handler import MessageHandler
from bot_config import LOG_LEVEL, LOG_FILE

# Configure logging
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)


class WhatsAppBotServer:
    """Main bot server that coordinates Node.js and Python components"""
    
    def __init__(self):
        self.message_handler = MessageHandler()
        self.nodejs_process = None
        self.python_server = None
        
    async def handle_incoming_message(self, request):
        """HTTP endpoint to receive messages from Node.js"""
        try:
            message_data = await request.json()
            logger.info(f"📩 Received message from Node.js: {message_data.get('from')}")
            
            # Handle message asynchronously
            await self.message_handler.handle_incoming_message(message_data)
            
            return web.json_response({'success': True})
            
        except Exception as e:
            logger.error(f"Error handling incoming message: {str(e)}", exc_info=True)
            return web.json_response({'success': False, 'error': str(e)}, status=500)
    
    async def start_python_server(self):
        """Start Python HTTP server to receive messages from Node.js"""
        app = web.Application()
        app.router.add_post('/whatsapp/incoming', self.handle_incoming_message)
        
        runner = web.AppRunner(app)
        await runner.setup()
        
        site = web.TCPSite(runner, 'localhost', 8001)
        await site.start()
        
        logger.info("🐍 Python server started on http://localhost:8001")
        self.python_server = runner
    
    def start_nodejs_server(self):
        """Start Node.js WhatsApp Web server"""
        try:
            bot_dir = Path(__file__).parent
            nodejs_script = bot_dir / 'whatsapp_server.js'
            
            logger.info("🚀 Starting Node.js WhatsApp server...")
            
            # Start Node.js process
            self.nodejs_process = subprocess.Popen(
                ['node', str(nodejs_script)],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1
            )
            
            # Print Node.js output
            def print_nodejs_output():
                for line in iter(self.nodejs_process.stdout.readline, ''):
                    if line:
                        print(f"[Node.js] {line.rstrip()}")
            
            import threading
            output_thread = threading.Thread(target=print_nodejs_output, daemon=True)
            output_thread.start()
            
            logger.info("✅ Node.js server process started")
            
        except Exception as e:
            logger.error(f"Failed to start Node.js server: {str(e)}")
            raise
    
    async def run(self):
        """Main run method"""
        try:
            print("=" * 80)
            print("🤖 ManKu WhatsApp Bot")
            print("=" * 80)
            print()
            
            # Start Python server
            await self.start_python_server()
            
            # Start Node.js server
            self.start_nodejs_server()
            
            print()
            print("✅ Bot is now running!")
            print("📱 Please scan QR code with your WhatsApp to authenticate")
            print("⏹️  Press Ctrl+C to stop the bot")
            print()
            
            # Keep running
            while True:
                await asyncio.sleep(1)
                
                # Check if Node.js process is still running
                if self.nodejs_process and self.nodejs_process.poll() is not None:
                    logger.error("❌ Node.js process has stopped")
                    break
                    
        except KeyboardInterrupt:
            logger.info("\n🛑 Received shutdown signal")
        except Exception as e:
            logger.error(f"❌ Error in main loop: {str(e)}", exc_info=True)
        finally:
            await self.shutdown()
    
    async def shutdown(self):
        """Graceful shutdown"""
        logger.info("🛑 Shutting down bot...")
        
        # Stop Node.js process
        if self.nodejs_process:
            logger.info("Stopping Node.js server...")
            self.nodejs_process.terminate()
            try:
                self.nodejs_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                logger.warning("Force killing Node.js process...")
                self.nodejs_process.kill()
        
        # Stop Python server
        if self.python_server:
            logger.info("Stopping Python server...")
            await self.python_server.cleanup()
        
        logger.info("✅ Bot stopped")


def main():
    """Main entry point"""
    bot = WhatsAppBotServer()
    
    # Setup signal handlers
    def signal_handler(sig, frame):
        logger.info("Received interrupt signal")
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Run bot
    try:
        asyncio.run(bot.run())
    except KeyboardInterrupt:
        pass
    except Exception as e:
        logger.error(f"Fatal error: {str(e)}", exc_info=True)
        sys.exit(1)


if __name__ == '__main__':
    main()
