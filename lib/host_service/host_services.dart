class HostService {
  // defined all the required strings.
  final String baseApiUrl = 'http://demoapp.citronsoftwares.com';
  final String getStudentByFilterUrl = '/api/Student/GetStudentByFilter';
  final String addAttendanceUrl = '/api/Attendance/AddAttendance';
  final String studentViewHomework = '/api/AppHomeWork/StudentHomework';
  final String addHomeworkUrl = '/api/HomeWork';
  final String loginApiUrl = '/api/User/CheckLogin';
  final String forgtpasswdUrl = '/api/User/ForgotPwd';
  final String changePasswdUrl = '/api/User/ChangePwd';
  final String getStudentByMobileNo =
      '/api/Student/GetStudentByMobileNo?mobno=';
  final String userRegisterUrl = '/api/User/Register';
  final String userVerifyUrl = '/api/User/Verify';
  // final String schoolCode = 'xyz';
  final String viewAttendance = '/api/Attendance/newGetAttendance';
  final String getClasses = '/api/Student/GetClasses';
  final String getSections = '/api/Student/GetSections';
  final String sendtoAll = '/api/AppMsg/SendToAll';
  final String multipleClass = '/api/AppMsg/MultipleClass';
  final String classWise = '/api/AppMsg/ClassWise';
  final String regnWise = '/api/AppMsg/RegnWise';
  final String getStudentByRegNo = '/api/Student/GetStudentByRegno';
  final String addHomework = '/api/HomeWork';
  final String teacherInfo = '/api/Teacher/GetTeacherInfo?userid=';
  final String teacherHomeworkReport = '/api/AppHomeWork/ViewHomework';
  final String teacherNotificationReport = '/api/AppMsg/DeliveryReport?page=';
  final String updateToken = '/api/User/UpdateToken';
  final String adminDashboardApi = '/api/Admin/AdminDashboard';
  final String adminGetStudentProfileByRegno = '/api/Admin/GetStudentProfile';
  final String schoolNameApiUrl =
      'http://app.online-sms.in/api/User/SchoolInfo2?username=';
  final String dueFeeUrl = '/api/Student/GetDue';
  final String feeDetailUrl = '/api/Student/GetFee';
  final String examResultUrl = '/api/exam/GetExamResult';
  final String getExamUrl = '/api/exam/GetExam';
  final String getLeaveListUrl = '/api/Student/GetLeaveList';
  final String addLeaveUrl = '/api/Student/AddLeave';
  final String teacherPermissionUrl = '/api/Teacher/GetPermission';
  final String onlineFeeDetail = 'api/Fee/OnlineFeeDetail';
  final String getGatewayDet = 'api/Fee/GetGatewayDet';
  final String getTransId = 'api/Fee/GetTransId';
  final String paymentBaseUrl = "testpay.easebuzz.in";
  final String getResponseOnlineTransactionUrl =
      "api/Fee/GetResponse_OnlineTransaction";
  final String getPunchDetailUrl = 'api/Admin/GetPunchDet?schoolid=';
  final String getTeacherPermissionUrl = 'api/Teacher/GetPermission';
  final String notificationDownloadStatus = 'api/AppMsg/DownloadStatus';
  final String eventCalender = '/api/Common/ViewCalender';
}
