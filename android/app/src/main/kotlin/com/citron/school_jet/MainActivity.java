package com.citron.school_jet;//package com.citron.school_jet;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.FlutterEngine;
import com.easebuzz.payment.kit.PWECouponsActivity;
import com.google.gson.Gson;
/*Atom require imports*/
import javax.crypto.Cipher;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.spec.KeySpec;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import datamodels.PWEStaticDataModel;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;



public class MainActivity extends FlutterActivity{
    private static final String CHANNEL = "easebuzz";
    private static final String CHANNEL_ONE = "flutter.dev/NDPSAESLibrary";
    MethodChannel.Result channel_result;
    private boolean start_payment = true;
    private static final int pswdIterations = 65536;
    private static final int keySize = 256;
    private static final byte[] ivBytes = new byte[]{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_ONE).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("NDPSAESInit")) {
                        try {
                            HashMap<String, Object> hashMap = (HashMap<String, Object>) call.arguments;
                            String AESMethod = (String) hashMap.get("AES_Method");
                            String key = (String) hashMap.get("encKey");
                            String encText = (String) hashMap.get("text");

                            if ("encrypt".equals(AESMethod)) {
                                String encryption = getAtomEncryption(encText, key);
                                result.success(encryption);
                            } else {
                                String decryption = getAtomDecryption(encText, key);
                                result.success(decryption);
                            }
                        } catch (Exception e) {
                            result.error("Error", "AES logic failed", null);
                            e.printStackTrace();
                        }
                    } else {
                        result.notImplemented();
                    }
                }
        );
    }


    private static String byteToHex(byte[] byData) {
        StringBuilder sb = new StringBuilder(byData.length * 2);
        for (byte b : byData) {
            int v = b & 0xFF;
            if (v < 16) {
                sb.append('0');
            }
            sb.append(Integer.toHexString(v));
        }
        return sb.toString().toUpperCase();
    }


    private static String getAtomEncryption(String plainText, String key) throws Exception {
        byte[] saltBytes = key.getBytes(StandardCharsets.UTF_8);
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA512");
        KeySpec spec = new PBEKeySpec(key.toCharArray(), saltBytes, pswdIterations, keySize);
        SecretKeySpec secretKey = new SecretKeySpec(factory.generateSecret(spec).getEncoded(), "AES");
        IvParameterSpec localIvParameterSpec = new IvParameterSpec(ivBytes);
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, secretKey, localIvParameterSpec);
        byte[] encryptedTextBytes = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
        return byteToHex(encryptedTextBytes);
    }

    private static byte[] hex2ByteArray(String sHexData) {
        byte[] rawData = new byte[sHexData.length() / 2];
        for (int i = 0; i < rawData.length; i++) {
            int index = i * 2;
            int v = Integer.parseInt(sHexData.substring(index, index + 2).trim(), 16);
            rawData[i] = (byte) v;
        }
        return rawData;
    }


    private static String getAtomDecryption(String encryptedText, String key) throws Exception {
        byte[] saltBytes = key.getBytes(StandardCharsets.UTF_8);
        byte[] encryptedTextBytes = hex2ByteArray(encryptedText);
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA512");
        KeySpec spec = new PBEKeySpec(key.toCharArray(), saltBytes, pswdIterations, keySize);
        SecretKeySpec secretKey = new SecretKeySpec(factory.generateSecret(spec).getEncoded(), "AES");
        IvParameterSpec localIvParameterSpec = new IvParameterSpec(ivBytes);
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, secretKey, localIvParameterSpec);
        byte[] decryptedTextBytes = cipher.doFinal(encryptedTextBytes);
        return new String(decryptedTextBytes, StandardCharsets.UTF_8);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        start_payment = true;

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        channel_result = result;
                        if (call.method.equals("payWithEasebuzz")) {
                            if (start_payment) {
                                start_payment = false;
                                startPayment(call.arguments);
                            }
                        }
                    }
                }
        );
    }
    private void startPayment(Object arguments) {
        try {
            Gson gson = new Gson();
            JSONObject parameters = new JSONObject(gson.toJson(arguments));
            Intent intentProceed = new Intent(getActivity(), PWECouponsActivity.class);
            intentProceed.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
            Iterator<?> keys = parameters.keys();
            while(keys.hasNext() ) {
                String value = "";
                String key = (String) keys.next();
                value = parameters.optString(key);
                if (key.equals("amount")){
                    Double amount = new Double(parameters.optString("amount"));
                    intentProceed.putExtra(key,amount);
                } else {
                    intentProceed.putExtra(key,value);
                }
            }
            startActivityForResult(intentProceed, PWEStaticDataModel.PWE_REQUEST_CODE );
        }catch (Exception e) {
            start_payment=true;
            Map<String, Object> error_map = new HashMap<>();
            Map<String, Object> error_desc_map = new HashMap<>();
            String error_desc = "exception occured:"+e.getMessage();
            error_desc_map.put("error","Exception");
            error_desc_map.put("error_msg",error_desc);
            error_map.put("result",PWEStaticDataModel.TXN_FAILED_CODE);
            error_map.put("payment_response",error_desc_map);
            channel_result.success(error_map);
        }
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

        if(data != null ) {
            if(requestCode==PWEStaticDataModel.PWE_REQUEST_CODE)
            {
                start_payment=true;
                JSONObject response = new JSONObject();
                Map<String, Object> error_map = new HashMap<>();
                if(data != null ) {
                    String result = data.getStringExtra("result");
                    String payment_response = data.getStringExtra("payment_response");
                    try {
                        JSONObject obj = new JSONObject(payment_response);
                        response.put("result", result);
                        response.put("payment_response", obj);
                        channel_result.success(com.citron.school_jet.JsonConverter.convertToMap(response));
                    }catch (Exception e){
                        Map<String, Object> error_desc_map = new HashMap<>();
                        error_desc_map.put("error",result);
                        error_desc_map.put("error_msg",payment_response);
                        error_map.put("result",result);
                        error_map.put("payment_response",error_desc_map);
                        channel_result.success(error_map);
                    }
                }else{
                    Map<String, Object> error_desc_map = new HashMap<>();
                    String error_desc = "Empty payment response";
                    error_desc_map.put("error","Empty error");
                    error_desc_map.put("error_msg",error_desc);
                    error_map.put("result","payment_failed");
                    error_map.put("payment_response",error_desc_map);
                    channel_result.success(error_map);
                }
            }else
            {
                super.onActivityResult(requestCode, resultCode, data);
            }
        }
    }

}
