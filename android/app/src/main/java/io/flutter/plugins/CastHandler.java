package com.example.soundnest;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.google.android.gms.cast.framework.CastContext;
import com.google.android.gms.cast.framework.CastSession;
import com.google.android.gms.cast.framework.SessionManagerListener;
import com.google.android.gms.cast.MediaLoadRequestData;
import com.google.android.gms.cast.MediaInfo;
import com.google.android.gms.cast.MediaMetadata;
import com.google.android.gms.cast.framework.media.RemoteMediaClient;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodCall;

public class CastHandler implements MethodCallHandler {

    private final Context context;
    private final MethodChannel channel;

    public CastHandler(Context context, MethodChannel channel) {
        this.context = context;
        this.channel = channel;
    }

    private CastSession getCastSession() {
        CastSession session = CastContext.getSharedInstance(context).getSessionManager().getCurrentCastSession();
        return (session != null && session.isConnected()) ? session : null;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        CastSession castSession = getCastSession();

        if (castSession == null) {
            result.error("NO_CAST_SESSION", "No active cast session", null);
            return;
        }

        RemoteMediaClient remoteMediaClient = castSession.getRemoteMediaClient();

        if (remoteMediaClient == null) {
            result.error("NO_REMOTE_CLIENT", "No remote media client", null);
            return;
        }

        switch (call.method) {
            case "playMedia":
                String url = call.argument("url");
                String title = call.argument("title");

                MediaMetadata mediaMetadata = new MediaMetadata(MediaMetadata.MEDIA_TYPE_MUSIC_TRACK);
                mediaMetadata.putString(MediaMetadata.KEY_TITLE, title != null ? title : "Audio");

                MediaInfo mediaInfo = new MediaInfo.Builder(url)
                        .setStreamType(MediaInfo.STREAM_TYPE_BUFFERED)
                        .setContentType("audio/mpeg")
                        .setMetadata(mediaMetadata)
                        .build();

                remoteMediaClient.load(mediaInfo, true);
                result.success(null);
                break;

            case "pause":
                remoteMediaClient.pause();
                result.success(null);
                break;

            case "resume":
                remoteMediaClient.play();
                result.success(null);
                break;

            case "stop":
                remoteMediaClient.stop();
                result.success(null);
                break;

            default:
                result.notImplemented();
                break;
        }
    }
}
