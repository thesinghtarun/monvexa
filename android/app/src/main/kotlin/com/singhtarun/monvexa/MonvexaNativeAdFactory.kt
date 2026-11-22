
package com.singhtarun.monvexa

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

class MonvexaNativeAdFactory(
    private val context: Context,
    private val layoutResId: Int
) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {

        val nativeAdView = LayoutInflater.from(context)
            .inflate(layoutResId, null) as NativeAdView

        val headlineView =
            nativeAdView.findViewById<TextView>(R.id.ad_headline)

        headlineView?.let {
            it.text = nativeAd.headline
            nativeAdView.headlineView = it
        }

        val bodyView =
            nativeAdView.findViewById<TextView>(R.id.ad_body)

        bodyView?.let {
            it.text = nativeAd.body
            it.visibility =
                if (nativeAd.body != null) View.VISIBLE else View.GONE
            nativeAdView.bodyView = it
        }

        val ctaView =
            nativeAdView.findViewById<Button>(R.id.ad_call_to_action)

        ctaView?.let {
            it.text = nativeAd.callToAction
            it.visibility =
                if (nativeAd.callToAction != null) View.VISIBLE else View.GONE
            nativeAdView.callToActionView = it
        }

        val iconView =
            nativeAdView.findViewById<ImageView>(R.id.ad_app_icon)

        iconView?.let {
            if (nativeAd.icon != null) {
                it.setImageDrawable(nativeAd.icon?.drawable)
                it.visibility = View.VISIBLE
            } else {
                it.visibility = View.GONE
            }
            nativeAdView.iconView = it
        }

        val advertiserView =
            nativeAdView.findViewById<TextView>(R.id.ad_advertiser)

        advertiserView?.let {
            it.text = nativeAd.advertiser
            it.visibility =
                if (nativeAd.advertiser != null) View.VISIBLE else View.GONE
            nativeAdView.advertiserView = it
        }

        val mediaView =
            nativeAdView.findViewById<MediaView>(R.id.ad_media)

        mediaView?.let {
            nativeAdView.mediaView = it
        }

        nativeAdView.setNativeAd(nativeAd)

        return nativeAdView
    }
}
