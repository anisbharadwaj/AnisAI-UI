import { useState, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Mic, MicOff, Cpu, Activity } from 'lucide-react';
import axios from 'axios';
ietAvatarState('error');
      setTimeout(() => setAvatarState('idle'), 3000);
    }
  };

  const toggleListening = () => {
    if (isListening) {
      setIsListening(false);
      setAvatarState('idle');
    } else {
      setIsListening(true);
      setAvatarState('listening');
      setTimeout(() => { handleSendMessage("What is my system status?"); setIsListening(false); }, 2000);
    }
  };

  return (
    <div className="relative w-screen h-screen bg-graphite text-white overflow-hidden flex flex-col">
      <Avatar3D state={avatarState} />
      <div className="absolute top-0 left-0 right-0 z-10 p-6 flex justify-between items-center">
        <div className="glass-panel px-4 py-2 rounded-full flex items-center gap-3">
          <div className={`w-2 h-2 rounded-full ${avatarState === 'idle' ? 'bg-green-500' : 'bg-anis-cyan animate-pulse'}`} />
          <span className="text-sm font-medium tracking-wider uppercase text-gray-300">ANIS AI v3.0</span>
        </div>
        <div className="glass-panel px-4 py-2 rounded-full flex items-center gap-3">
          <Cpu size={16} className="text-anis-cyan" />
          <span className="text-xs text-gray-400">LOCAL CORE: ONLINE</span>
        </div>
      </div>
      <div className="absolute inset-0 z-10 flex flex-col items-center justify-end pb-32 pointer-events-none">
        <div className="w-full max-w-2xl px-6 pointer-events-auto">
          <AnimatePresence>
            {conversation.length > 0 && (
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="glass-panel rounded-2xl p-6 max-h-64 overflow-y-auto mb-6">
                {conversation.map((msg, idx) => (
                  <div key={idx} className={`mb-4 last:mb-0 ${msg.role === 'user' ? 'text-right' : 'text-left'}`}>
                    <span className={`text-xs uppercase tracking-widest ${msg.role === 'user' ? 'text-anis-blue' : 'text-anis-cyan'}`}>{msg.role === 'user' ? 'You' : 'ANIS'}</span>
                    <p className="text-lg mt-1 text-gray-100">{msg.text}</p>
                  </div>
                ))}
                <div ref={chatEndRef} />
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
      <div className="absolute bottom-0 left-0 right-0 z-10 p-8 flex justify-center items-center gap-6">
        <motion.button whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }} onClick={toggleListening} className={`glass-panel w-20 h-20 rounded-full flex items-center justify-center transition-all duration-300 ${isListening ? 'bg-anis-cyan/20 border-anis-cyan shadow-[0_0_30px_rgba(0,240,255,0.3)]' : 'hover:bg-white/5'}`}>
          {isListening ? <MicOff size={32} className="text-anis-cyan" /> : <Mic size={32} className="text-gray-300" />}
        </motion.button>
        <div className="glass-panel px-6 py-3 rounded-full flex items-center gap-3">
          <Activity size={16} className="text-anis-cyan" />
          <span className="text-sm text-gray-300 capitalize">{avatarState}...</span>
        </div>
      </div>
    </div>
  );
}

export default App;
