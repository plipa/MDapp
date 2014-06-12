/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package Mock;

import java.security.InvalidKeyException;
import java.security.SignatureException;

/**
 *
 * @author sevar
 */
public class DoctorsCard {
    
    Crypto crypto;

    public DoctorsCard() {
        crypto = new Crypto();
        
    }
    public byte[] sign(byte[] msg) throws InvalidKeyException, SignatureException{
        return crypto.sign(msg);
    }
    
}
