import ddf.minim.*;

Minim minim;
AudioPlayer song;

// String song_path = "../data/let_it_be.mp3";
// String features_path = "../data/let_it_be_audio_features.json";


String song_path = "../data/wknd_w.wav";
String features_path = "../data/blinding_lights_audio_features.json";

int ms;
float curr_time;
int init_time;
float time_pos;

JSONObject json;

float test_point = 0.0;

float point_pos;
float point_x;
float point_y;
float total_pixels;

float song_duration;

float duration_limit = 60.0;

int pitch_line_wgt = 10;
int vert_div = 14 * pitch_line_wgt;
int hor_div = 5;

float tatum_line_wgt = 0.5;
float beat_line_wgt = 1.5;
float bar_line_wgt = 3;
float section_line_wgt = 4;

color tatum_col;
color beat_col;
color bar_col;
color section_col;

JSONArray tatums;
JSONArray beats;
JSONArray bars;
JSONArray sections;
JSONArray segments;

PGraphics pg, play_pg;
int pg_w = 720;
int pg_h = 8400;
String[] pitch_names = {"C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B"};

void setup() {
	size(720, 960);
	
	colorMode(HSB, 360, 1.0, 1.0, 1.0);
	imageMode(CORNERS);

	pg = createGraphics(pg_w, pg_h);
	play_pg = createGraphics(pg_w, pg_h);

	pg.beginDraw();
	pg.background(255);
	pg.textSize(12);

	pg.colorMode(HSB, 360, 1.0, 1.0, 1.0);
	tatum_col = color(0.0, 0.0, 0.1, 1.0);
	beat_col = color(0.0, 0.0, 0.0 ,1.0);
	bar_col = color(0.0, 0.0, 0.0 ,1.0);
	section_col = color(120, 1.0, 1.0, 1.0);

	pg.rectMode(CORNERS);
	pg.strokeCap(SQUARE);

	//pg.endDraw();

	total_pixels = pg_w*pg_h;
	println(total_pixels);

	json = loadJSONObject(features_path);

	JSONObject track_info = json.getJSONObject("track");
	
	song_duration = track_info.getFloat("duration");
	tatums = json.getJSONArray("tatums");
	beats = json.getJSONArray("beats");
	bars = json.getJSONArray("bars");
	sections = json.getJSONArray("sections");
	segments = json.getJSONArray("segments");

	println("song_duration: "+song_duration);

	minim = new Minim(this);
	song = minim.loadFile(song_path);
	println(float(song.length())/1000.0);

	subdivisionLines(tatums, tatum_line_wgt, tatum_col);
	subdivisionLines(beats, beat_line_wgt, beat_col);
	subdivisionLines(bars, bar_line_wgt, bar_col);
	
	drawSegments(segments);
	
	subdivisionLines(sections, section_line_wgt, section_col);

	drawNoteNames();

	// pg.beginDraw();

	// pg.fill(120,1.0,1.0,1.0);
	// pg.text("C", 10, 10);

	song.play();

	pg.endDraw();
	play_pg.beginDraw();
	play_pg.image(pg, 0, 0, pg_w, pg_h);
	play_pg.endDraw();

}

void draw() {
	play_pg.beginDraw();
	play_pg.image(pg, 0, 0, pg_w, pg_h);

	time_pos = map(float(song.position())/1000.0, 0.0, song_duration, 0, total_pixels);


	point_x = ((time_pos/vert_div)%pg_w);
	point_y = (time_pos/pg_w) - ((time_pos/pg_w)%vert_div);

	//stroke(0, 0, 0.0, 1.0);
	play_pg.strokeWeight(8);
	play_pg.stroke(0,0,255);
	play_pg.line(point_x, point_y, point_x, point_y+(12*pitch_line_wgt));

	play_pg.endDraw();
	int offset_operator = height-vert_div;
	float img_y_off = -offset_operator*floor((point_y)/offset_operator);
	image(play_pg,0,img_y_off,pg_w, pg_h + img_y_off);


}

void drawNoteNames(){
	pg.beginDraw();
	pg.fill(0,0,1,1);
	for (int i = 0; i < floor(pg_h/vert_div); ++i) {
		int y_init = i*vert_div;
		for (int j = 0; j < pitch_names.length; ++j) {
			float yoff = (12-j)*pitch_line_wgt;
			for (int k = 0; k < 8; ++k) {
				float xoff = k*(pg_w/8);
				pg.text(pitch_names[j], xoff, y_init+yoff);
			}
			
			
		}
	}
	pg.endDraw();
}

void subdivisionLines(JSONArray subdiv, float line_wgt, color line_col){
	pg.beginDraw();
	pg.stroke(line_col);
	pg.strokeWeight(line_wgt);

	for (int i = 0; i < subdiv.size(); ++i) {
		JSONObject o = subdiv.getJSONObject(i);

		float pos_time = o.getFloat("start");

		point_pos = map(pos_time, 0.0, song_duration, 0, total_pixels);
		//println(point_pos);
		point_x = ((point_pos/vert_div)%pg_w);
		point_y = ((point_pos)/pg_w) - ((point_pos/pg_w)%vert_div);
		pg.beginDraw();
		pg.line(point_x, point_y, point_x, point_y+(12*pitch_line_wgt));
		
	}
	pg.endDraw();
}

void drawSegments(JSONArray segs){
	pg.beginDraw();
	for (int i = 0; i < segs.size()-1; ++i) {
		JSONObject o1 = segs.getJSONObject(i);
		JSONObject o2 = segs.getJSONObject(i+1);

		JSONArray pitches = o1.getJSONArray("pitches");

		float point_pos1 = map(o1.getFloat("start"), 0.0, song_duration, 0, total_pixels);
		float point_pos2 = map(o2.getFloat("start"), 0.0, song_duration, 0, total_pixels);

		float point_x1 = ((point_pos1/vert_div)%pg_w);
		float point_y1 = (point_pos1/pg_w) - ((point_pos1/pg_w)%vert_div);

		float point_x2 = ((point_pos2/vert_div)%pg_w);
		float point_y2 = (point_pos2/pg_w) - ((point_pos2/pg_w)%vert_div);

		float confidence_alpha = map(o1.getFloat("confidence"), 0.0, 1.0, 0.5, 0.0);

		pg.fill(0, 1.0, 1.0, confidence_alpha); //red
		pg.noStroke();

		pg.rect(point_x1, point_y1, point_x2, point_y2+12*pitch_line_wgt); //confidence of the segment

		for (int j = 0; j < pitches.size(); ++j) {
			float pitch = pitches.getFloat(j);
			float yoff = (11-j)*pitch_line_wgt;
			pg.noStroke();
			pg.fill(0.0, 0.0, 0.0, pitch);
			if (point_y2==point_y1) {
				pg.rect(point_x1, point_y1+yoff, point_x2, point_y2+yoff+pitch_line_wgt);
			}
			else if (point_y2>point_y1) {
				pg.rect(point_x1, point_y1+yoff, width, point_y1+yoff+pitch_line_wgt);
				pg.rect(0, point_y2+yoff, point_x2, point_y2+yoff+pitch_line_wgt);
			}
			
		}
	}
	pg.endDraw();
}