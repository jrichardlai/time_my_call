package org.ruboto.callbacks;

import org.jruby.Ruby;
import org.jruby.javasupport.util.RuntimeHelpers;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.javasupport.JavaUtil;
import org.jruby.exceptions.RaiseException;
import org.ruboto.Script;

public class RubotoSoundPoolOnLoadCompleteListener implements android.media.SoundPool.OnLoadCompleteListener {
  private Ruby __ruby__;

  public static final int CB_LOAD_COMPLETE = 0;
  private IRubyObject[] callbackProcs = new IRubyObject[1];



  private Ruby getRuby() {
    if (__ruby__ == null) __ruby__ = Script.getRuby();
    return __ruby__;
  }

  public void setCallbackProc(int id, IRubyObject obj) {
    callbackProcs[id] = obj;
  }
	
  public void onLoadComplete(android.media.SoundPool soundPool, int sampleId, int status) {
    if (callbackProcs[CB_LOAD_COMPLETE] != null) {
      try {
        RuntimeHelpers.invoke(getRuby().getCurrentContext(), callbackProcs[CB_LOAD_COMPLETE], "call" , JavaUtil.convertJavaToRuby(getRuby(), soundPool), JavaUtil.convertJavaToRuby(getRuby(), sampleId), JavaUtil.convertJavaToRuby(getRuby(), status));
      } catch (RaiseException re) {
        re.printStackTrace();
      }
    }
  }
}
