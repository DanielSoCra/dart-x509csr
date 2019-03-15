/*
 * lib/src/dn.dart
 *
 * David Janes
 * 2018-03-13
 *
 * Copyright [2019] David P. Janes
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:asn1lib/asn1lib.dart';
import 'dart:typed_data';

/*
 *  Encode as ASN1 e.g. 
  {
    "CN": "www.davidjanes.com",
    "O": "Consensas",
    "L": "Toronto",
    "S": "Ontario",
    "C": "CA",
  }
 */
ASN1Object makeDN(Map<String, String> d) {
  var DN = ASN1Sequence();

  d.forEach((name, value) {
    ASN1ObjectIdentifier oid = ASN1ObjectIdentifier.fromName(name);
    if (oid == null) {
      print("x509csr.makeDN: name=${name} not found");
      return;
    }

    ASN1Object ovalue;

    switch (name.toUpperCase()) {
      case "C":
        {
          ovalue = ASN1PrintableString(value);
        }
        break;
      case "CN":
      case "O":
      case "L":
      case "S":
      default:
        {
          ovalue = ASN1UTF8String(value);
        }
        break;
    }

    if (ovalue == null) {
      print("x509csr.makeDN: value=${value} not processed");
      return;
    }

    var pair = ASN1Sequence();
    pair.add(oid);
    pair.add(ovalue);

    var pairset = ASN1Set();
    pairset.add(pair);

    DN.add(pairset);
  });

  return DN;
}

/*
 */
ASN1Object makeDNSignature(Uint8List signedDN) {
  var outer = ASN1Sequence();

  var inner = ASN1Sequence();
  outer.add(inner);

  inner.add(ASN1ObjectIdentifier.fromName("rsaEncryption"));
  inner.add(ASN1BitString(signedDN));
  inner.add(ASN1Null());

  return outer;
}
