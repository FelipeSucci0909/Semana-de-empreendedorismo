package br.fgv.sce.zelo;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/** App Android do Zelo: abre a mesma demo do site (assets/index.html) em tela cheia. */
public class MainActivity extends Activity {
    private static final int FUNDO = Color.parseColor("#EEF4F3");
    private WebView web;

    @Override
    protected void onCreate(Bundle estado) {
        super.onCreate(estado);
        Window janela = getWindow();
        janela.setStatusBarColor(FUNDO);
        janela.setNavigationBarColor(Color.WHITE);
        int flags = View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) flags |= View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
        janela.getDecorView().setSystemUiVisibility(flags);

        web = new WebView(this);
        web.setBackgroundColor(FUNDO);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setTextZoom(100);
        // A página usa "ZeloApp" para esconder o botão de baixar o APK.
        s.setUserAgentString(s.getUserAgentString() + " ZeloApp/1.0");
        web.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView v, WebResourceRequest req) {
                Uri url = req.getUrl();
                if ("file".equals(url.getScheme())) return false;
                startActivity(new Intent(Intent.ACTION_VIEW, url));
                return true;
            }
        });
        setContentView(web);

        if (estado != null) web.restoreState(estado);
        else web.loadUrl("file:///android_asset/index.html");
    }

    @Override
    protected void onSaveInstanceState(Bundle saida) {
        super.onSaveInstanceState(saida);
        web.saveState(saida);
    }

    /** O botão voltar navega dentro do app; na tela inicial, fecha. */
    @Override
    @SuppressWarnings("deprecation")
    public void onBackPressed() {
        web.evaluateJavascript("window.zeloBack ? window.zeloBack() : false", valor -> {
            if (!"true".equals(valor)) finish();
        });
    }
}
