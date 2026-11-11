import importlib.util,json,tempfile,unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location("hxwd_config",Path(__file__).with_name("configure.py"));m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
class ConfigTests(unittest.TestCase):
 def test_preserves_media_and_switches_model(self):
  with tempfile.TemporaryDirectory() as t:
   p=Path(t);(p/".env").write_text("VIDEO_PROVIDER=ark\nOPENAI_MODEL=old\nOPENAI_API_KEY=old\n")
   a=p/"activation.json";a.write_text(json.dumps({"apiKey":"unit-test-placeholder-only","model":"claude-haiku-5-5","baseUrl":"https://api.apilio.ai/v1"}))
   m.configure(p,a);m.configure(p,a);s=(p/".env").read_text()
   self.assertIn("IMG_MODEL=gpt-image-2-all",s);self.assertIn("VIDEO_PROVIDER=ark",s);self.assertEqual(s.count("OPENAI_MODEL="),1);self.assertIn("EASEL_CHAT_TRANSPORT=http",s)
 def test_rejects_injection_before_mutation(self):
  with tempfile.TemporaryDirectory() as t:
   p=Path(t);(p/".env").write_text("UNCHANGED=yes\n");a=p/"a.json";a.write_text(json.dumps({"apiKey":"bad\nINJECTED=value","model":"claude-haiku-5-5","baseUrl":"https://api.apilio.ai/v1"}))
   with self.assertRaises(ValueError):m.configure(p,a)
   self.assertEqual((p/".env").read_text(),"UNCHANGED=yes\n")
 def test_rejects_other_endpoint(self):
  with tempfile.TemporaryDirectory() as t:
   p=Path(t);a=p/"a.json";a.write_text(json.dumps({"apiKey":"unit-test-placeholder-only","model":"claude-haiku-5-5","baseUrl":"http://bad.invalid"}))
   with self.assertRaises(ValueError):m.configure(p,a)
if __name__=="__main__":unittest.main()
