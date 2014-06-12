/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package Mock;

import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PrivateKey;
import java.security.Provider;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.Signature;
import java.security.SignatureException;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.logging.Level;
import java.util.logging.Logger;
import mdapp.Hex;
import org.bouncycastle.jce.ECNamedCurveTable;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.jce.spec.ECNamedCurveParameterSpec;

/**
 *
 * @author sevar
 */
public class Crypto {

    private Signature signature = null;
    Provider bc = null;
    private PrivateKey sk;
    private PublicKey pk;

    public Crypto(String sk, String pk) throws NoSuchProviderException, InvalidKeySpecException {
        try {
            KeyFactory fact = KeyFactory.getInstance("ECDSA", bc);
            this.sk = fact.generatePrivate(new PKCS8EncodedKeySpec(Hex.stringHexToByteHex(sk)));
            this.pk = fact.generatePublic(new X509EncodedKeySpec(Hex.stringHexToByteHex(pk)));

            bc = new BouncyCastleProvider();
            signature = Signature.getInstance("SHA256WithECDSA", bc);
        } catch (NoSuchAlgorithmException ex) {
            Logger.getLogger(Crypto.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public Crypto() {
        try {

            bc = new BouncyCastleProvider();
            signature = Signature.getInstance("SHA256WithECDSA", bc);
            try {
                genKeys();
            } catch (InvalidKeySpecException ex) {
                Logger.getLogger(Crypto.class.getName()).log(Level.SEVERE, null, ex);
            } catch (NoSuchProviderException ex) {
                Logger.getLogger(Crypto.class.getName()).log(Level.SEVERE, null, ex);
            } catch (InvalidAlgorithmParameterException ex) {
                Logger.getLogger(Crypto.class.getName()).log(Level.SEVERE, null, ex);
            }

        } catch (NoSuchAlgorithmException ex) {
            Logger.getLogger(Crypto.class.getName()).log(Level.SEVERE, null, ex);
        }

    }

    public byte[] sign(byte[] data) throws InvalidKeyException, SignatureException {
        signature.initSign(sk);
        signature.update(data);
        return signature.sign();
    }

    public boolean verify(byte[] msg, byte[] sign) throws InvalidKeyException, SignatureException {
        signature.initVerify(pk);
        signature.update(msg);
        return signature.verify(sign);
    }

    public void genKeys() throws InvalidKeySpecException, NoSuchAlgorithmException, NoSuchProviderException, InvalidAlgorithmParameterException {

        ECNamedCurveParameterSpec ecSpec = ECNamedCurveTable.getParameterSpec("secp521r1");
        KeyPairGenerator g = KeyPairGenerator.getInstance("ECDSA", bc);
        g.initialize(ecSpec, new SecureRandom());
        KeyPair pair = g.generateKeyPair();
        pk = pair.getPublic();
        sk = pair.getPrivate();
    }

    public byte[] sendPK() {
        return pk.getEncoded();
    }

    public void printSK() {
        System.out.println(Hex.byteHextoStringHex(getSK()));
    }

    public void printPK() {
        System.out.println(Hex.byteHextoStringHex(getPK()));
    }

    private byte[] getSK() {
        return sk.getEncoded();
    }

    private byte[] getPK() {
        return pk.getEncoded();
    }
}
