public with sharing class HerokuToken {

    private static String kHexChars = '0123456789ABCDEF';

    public static String headerToken() {

        String guid = '';
        Integer nextByte = 0;

        for (Integer i=0; i<8; i++) {

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==3) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==6) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            String key = null;
            
            while((key = getCharAtIndex(kHexChars, nextByte >> 4)) == null );
            
            guid += key;
        }

        guid = guid + generateToken(guid);//+'DevSaran'
                
        return EncodingUtil.base64Encode(Blob.valueOf(guid));
    }

    public static String getCharAtIndex(String str, Integer index) {

        if (str == null) return null;

        if (str.length() <= 0) return str;    

        if (index == str.length()) return null;    

        return str.substring(index, index+1);
    }
    
    public static String generateToken(String guid){
        String hexCode = '';
        for(Integer i=0; i<guid.length(); i++){
            hexCode += guid.charAt(i);
        }
        
        String token = '';
        for(Integer i=0; i<hexCode.length(); i++){
            token += hexCode.charAt(i) & (hexCode.charAt(i) << 4);
        }
        
        return token;
    }
}