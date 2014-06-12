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
public class PatientCard {

    Crypto crypto;

    public PatientCard() {
        crypto = new Crypto();
        
    }
    public byte[] sign(byte[] msg) throws InvalidKeyException, SignatureException{
        return crypto.sign(msg);
    }
}
