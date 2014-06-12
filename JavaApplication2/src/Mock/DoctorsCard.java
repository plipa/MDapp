/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package Mock;

import java.security.InvalidKeyException;
import java.security.SignatureException;
import java.util.Random;

/**
 *
 * @author sevar
 */
public class DoctorsCard {

    private final int doctors_id;
    private Crypto crypto;

    public int getID() {
        return doctors_id;
    }

    public DoctorsCard() {
        crypto = new Crypto();
        Random r = new Random();
        doctors_id = r.nextInt();

    }

    public byte[] sign(byte[] msg) throws InvalidKeyException, SignatureException {
        return crypto.sign(msg);
    }
}
