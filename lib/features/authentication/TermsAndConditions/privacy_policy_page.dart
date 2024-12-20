import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE966A0),
        title: const Text(
          'นโยบายความเป็นส่วนตัว',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
         iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. บทนำ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '1.1 ขอต้อนรับสู่ Swap My Style ("Swap My Style", "เรา", "แอปพลิเคชัน") Swap My Style เราตระหนักถึงความสำคัญของข้อมูลส่วนบุคคลที่คุณมอบให้แก่เรา และเชื่อว่าเรามีหน้าที่รับผิดชอบในการจัดการ ปกป้อง และดำเนินการข้อมูลส่วนบุคคลของคุณอย่างเหมาะสม นโยบายความเป็นส่วนตัวนี้ ("นโยบายความเป็นส่วนตัว" หรือ "นโยบาย") ได้รับการออกแบบมาเพื่อช่วยให้คุณเข้าใจเกี่ยวกับวิธีที่เราเก็บรวบรวม ใช้ เปิดเผย และ/หรือดำเนินการข้อมูลส่วนบุคคลที่คุณมอบให้แก่เราและ/หรือข้อมูลของคุณที่เราครอบครองไม่ว่าจะในปัจจุบันหรืออนาคต รวมทั้งยังเป็นข้อมูลประกอบการตัดสินใจก่อนที่คุณจะให้ข้อมูลส่วนตัวใดๆ แก่เรา โปรดอ่านนโยบายความเป็นส่วนตัวนี้โดยละเอียด',
            ),
            SizedBox(height: 10),
            Text(
              '1.2 "ข้อมูลส่วนบุคคล" หมายถึง ข้อมูลเกี่ยวกับบุคคลไม่ว่าจริงหรือเท็จที่สามารถใช้เป็นข้อมูลที่ระบุตัวตนของบุคคลผู้นั้น หรือจากข้อมูลดังกล่าวหรือข้อมูลอื่นๆ ที่องค์กรมีหรืออาจสามารถเข้าถึงได้ ตัวอย่างข้อมูลส่วนบุคคลที่พบบ่อยได้แก่ ชื่อ นามสกุล และข้อมูลการติดต่อ',
            ),
            SizedBox(height: 10),
            Text(
              '1.3 ในการใช้บริการ การลงทะเบียนบัญชีกับเรา หรือเข้าถึงบริการ คุณ ได้รับทราบและตกลงว่าคุณยอมรับข้อปฏิบัติ ข้อกำหนด และ/หรือนโยบายที่กำหนดไว้ในนโยบายความเป็นส่วนตัวนี้ และคุณยินยอมให้เราเก็บรวบรวม ใช้ เปิดเผย และ/หรือดำเนินการข้อมูลส่วนบุคคลของคุณดังที่ระบุไว้ในนโยบายความเป็นส่วนตัวนี้ หากคุณไม่ยินยอมให้เราดำเนินการข้อมูลส่วนบุคคลของคุณดังที่ระบุไว้ในนโยบายความเป็นส่วนตัวนี้ โปรดอย่าใช้บริการของเรา',
            ),
            SizedBox(height: 20),
            Text(
              '2. Swap My Style จะเก็บรวบรวมข้อมูลส่วนบุคคลเมื่อใด',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'เราจะ/อาจเก็บรวบรวมข้อมูลส่วนบุคคลของคุณเมื่อ:',
            ),
            Text('  (a) เมื่อคุณลงทะเบียนและ/หรือใช้บริการของเรา'),
            Text('  (b) เมื่อคุณให้ความคิดเห็นหรือคำร้องเรียนแก่เรา'),
            Text('  (c) เมื่อคุณส่งข้อมูลส่วนบุคคลของคุณให้แก่เราด้วยเหตุผลใดก็ตาม'),
            SizedBox(height: 10),
            Text(
              'นโยบายดังกล่าวข้างต้นไม่ได้อ้างไว้โดยละเอียดถี่ถ้วนและเป็นเพียงตัวอย่างทั่วไปเมื่อเราเก็บรวบรวมข้อมูลส่วนบุคคลเกี่ยวกับคุณ',
            ),
            SizedBox(height: 20),
            Text(
              '3. Swap My Style จะเก็บรวบรวมข้อมูลส่วนบุคคลใดไว้บ้าง',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '3.1 ข้อมูลส่วนบุคคลที่ Swap My Style อาจเก็บรวบรวมอาจรวมถึงแต่ไม่จำกัดเพียง:',
            ),
            Text('• ชื่อ'),
            Text('• นามสกุล'),
            Text('• ที่อยู่อีเมล'),
            Text('• หมายเลขโทรศัพท์'),
            Text('• ข้อมูลอื่นใดเกี่ยวกับผู้ใช้เมื่อผู้ใช้ลงทะเบียนเข้าใช้บริการของเรา และเมื่อผู้ใช้ใช้บริการ รวมถึงข้อมูลที่เกี่ยวกับวิธีการใช้บริการของผู้ใช้'),
            Text('• ข้อมูลรวมเกี่ยวกับเนื้อหาที่ผู้ใช้เข้าไปมีส่วนร่วม'),
            SizedBox(height: 10),
            Text(
              '3.2 หากคุณไม่ประสงค์ให้เราเก็บรวบรวมข้อมูล/ข้อมูลส่วนบุคคลดังที่กล่าวมาข้างต้น คุณอาจยกเลิกได้ทุกเมื่อโดยการแจ้งความประสงค์ให้เจ้าหน้าที่คุ้มครองข้อมูลของเราทราบเป็นลายลักษณ์อักษร คุณสามารถอ่านข้อมูลเพิ่มเติมเกี่ยวกับการยกเลิกได้ที่ส่วนด้านล่างในหัวข้อ "วิธีที่คุณสามารถยกเลิก ลบ ร้องขอการเข้าถึง หรือแก้ไขข้อมูลที่คุณให้แก่เรา" อย่างไรก็ตาม โปรดจำไว้ว่าการยกเลิกการเก็บรวบรวมข้อมูลส่วนบุคคลหรือถอนความยินยอมในการเก็บรวบรวม ใช้ หรือดำเนินการข้อมูลส่วนบุคคลของคุณกับเรานั้นอาจส่งผลต่อการใช้บริการของคุณ',
            ),
            SizedBox(height: 20),
            Text(
              '4. การตั้งค่าบัญชี',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'เพื่อเข้าใช้งานฟังก์ชันการทำงานบางประการของบริการ คุณจะต้องสร้างบัญชีผู้ใช้ซึ่งคุณจำเป็นต้องส่งข้อมูลส่วนบุคคลบางอย่าง เมื่อคุณลงทะเบียนและสร้างบัญชี เราจะกำหนดให้คุณระบุชื่อและที่อยู่อีเมลของคุณ รวมถึงชื่อผู้ใช้ที่คุณเลือก เรายังขอข้อมูลบางอย่างเกี่ยวกับตัวคุณ ได้แก่ หมายเลขโทรศัพท์ ที่อยู่อีเมล และรูปประจำตัว เมื่อเปิดใช้งานบัญชีของคุณ คุณจะต้องเลือกที่อยู่อีเมลและรหัสผ่าน คุณจะต้องใช้ที่อยู่อีเมลและรหัสผ่านเพื่อที่คุณจะสามารถเข้าถึงและรักษาบัญชีของคุณได้อย่างปลอดภัย',
            ),
            SizedBox(height: 20),
            Text(
              '5. เรามีวิธีการใช้ข้อมูลที่คุณให้แก่เราอย่างไรบ้าง',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '5.1 เราอาจเก็บรวบรวม ใช้ เปิดเผย และ/หรือดำเนินการข้อมูลส่วนบุคคลของคุณเพื่อวัตถุประสงค์อย่างน้อยหนึ่งวัตถุประสงค์ดังต่อไปนี้',
            ),
            Text('  (a) เพื่อจัดการ ดำเนินการ ให้ และ/หรือบริหารการใช้งานของคุณและ/หรือเพื่อเข้าถึงบริการของเรา'),
            Text('  (b) เพื่อป้องกันความปลอดภัยและสิทธิ์ ทรัพย์สินส่วนบุคคล หรือความปลอดภัยของบุคคลอื่น'),
            Text('  (c) เพื่อระบุตัวตนและ/หรือการตรวจสอบความถูกต้อง'),
            Text('  (d) เพื่อตอบสนองต่อกระบวนการทางกฎหมาย หรือปฏิบัติตามหรือเป็นไปตามกฎหมายที่บังคับใช้ ข้อกำหนดของภาครัฐหรือตามกฎข้อบังคับภายใต้อำนาจการพิจารณาที่เกี่ยวข้อง รวมถึงแต่ไม่จำกัดเพียง การดูแลให้เป็นไปตามข้อกำหนดเพื่อทำให้การเปิดเผยข้อมูลนั้นเป็นไปตามข้อกำหนดของกฎหมายที่ Swap My Style ต้องปฏิบัติตาม'),
            SizedBox(height: 10),
            Text(
              '5.2 เนื่องจากวัตถุประสงค์ที่เราจะเก็บรวบรวม ใช้ เปิดเผย และ/หรือดำเนินการข้อมูลส่วนบุคคลของคุณขึ้นอยู่กับสถานการณ์เฉพาะหน้า วัตถุประสงค์ดังกล่าวอาจไม่ปรากฎในข้างต้น อย่างไรก็ตาม เราจะแจ้งให้คุณทราบถึงวัตถุประสงค์ดังกล่าว ณ เวลาที่ขอรับความยินยอมจากคุณ เว้นแต่การดำเนินการข้อมูลที่เกี่ยวข้องโดยไม่ได้รับความยินยอมจากคุณนั้นเป็นไปตามที่กฎหมายเกี่ยวกับการคุ้มครองข้อมูลส่วนบุคคลกำหนดไว้',
            ),
            SizedBox(height: 20),
            Text(
              '6. การแบ่งปันข้อมูลจากบริการ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '6.1 เราไม่จะแบ่งปันข้อมูลส่วนบุคคลของคุณกับบุคคลภายนอก นอกเหนือจากการดำเนินการที่คุณยินยอม หรือหากกฎหมายกำหนด หรือเพื่อการดำเนินงานของบริการ โดยเฉพาะอย่างยิ่ง เราจะไม่แบ่งปันข้อมูลส่วนบุคคลของคุณกับผู้ให้บริการที่ไม่ได้เป็นเจ้าของหรือควบคุมโดย Swap My Style เว้นแต่มีการแจ้งให้คุณทราบล่วงหน้าและคุณยินยอม',
            ),
            SizedBox(height: 20),
            Text(
              '7. เราเก็บรักษาข้อมูลของคุณไว้นานแค่ไหน',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '7.1 เราจะเก็บข้อมูลส่วนบุคคลของคุณไว้ตราบเท่าที่คุณใช้บริการของเรา และ/หรือเป็นไปตามกฎหมายหรือข้อบังคับที่ใช้บังคับ ณ เวลานั้น',
            ),
            SizedBox(height: 20),
            Text(
              '8. การรักษาความปลอดภัยของข้อมูล',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '8.1 เราจะดำเนินการตามมาตรการรักษาความปลอดภัยที่เหมาะสมเพื่อปกป้องข้อมูลส่วนบุคคลของคุณจากการเข้าถึง การใช้ หรือการเปิดเผยที่ไม่ได้รับอนุญาต',
            ),
            SizedBox(height: 20),
            Text(
              '9. สิทธิของคุณในข้อมูลส่วนบุคคล',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '9.1 คุณมีสิทธิในการเข้าถึงข้อมูลส่วนบุคคลของคุณ และในการร้องขอให้เราลบหรือแก้ไขข้อมูลส่วนบุคคลที่เราเก็บรักษาไว้เกี่ยวกับคุณ',
            ),
            SizedBox(height: 20),
            Text(
              '10. การเปลี่ยนแปลงนโยบาย',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '10.1 เราอาจปรับปรุงนโยบายความเป็นส่วนตัวนี้เป็นระยะๆ โดยจะแจ้งให้คุณทราบถึงการเปลี่ยนแปลงที่สำคัญ โปรดตรวจสอบนโยบายความเป็นส่วนตัวนี้เป็นประจำเพื่อดูข้อมูลล่าสุดเกี่ยวกับวิธีการจัดการข้อมูลส่วนบุคคลของคุณ',
            ),
            SizedBox(height: 20),
            Text(
              '11. การติดต่อเรา',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '11.1 หากคุณมีคำถามเกี่ยวกับนโยบายความเป็นส่วนตัวนี้ หรือการดำเนินการของเราเกี่ยวกับข้อมูลส่วนบุคคลของคุณ โปรดติดต่อเราได้ที่ supansak654@gmail.com',
            ),
          ],
        ),
      ),
    );
  }
}
