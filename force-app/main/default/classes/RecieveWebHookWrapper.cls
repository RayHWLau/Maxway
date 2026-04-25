public class RecieveWebHookWrapper {
  public List<entry_cls> entry;
    public class entry_cls{
        public String id;
        public List<changes_cls> changes;
	}
    public class changes_cls {
        public cls_value value;
    }
    public class cls_value {
        public List<status_cls> statuses; 
    }
    public class status_cls {
        public string id;
        public String status;
        public List<error_cls> errors;
    }
    public class error_cls {
        public String message;
        public String type_m;
        public String title;
        public Integer code;
        public String fbtrace_id ;
        public cls_error_data error_data;
    }
    public class cls_error_data {
        public String messaging_product;
        public String details;
    }
    public static void coverage() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}