namespace N2PaletteConverter
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.inPictureBox = new System.Windows.Forms.PictureBox();
            this.outPictureBox = new System.Windows.Forms.PictureBox();
            this.btn_Load_IMG = new System.Windows.Forms.Button();
            this.button3 = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.inPictureBox)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.outPictureBox)).BeginInit();
            this.SuspendLayout();
            // 
            // inPictureBox
            // 
            this.inPictureBox.BackColor = System.Drawing.SystemColors.ActiveCaptionText;
            this.inPictureBox.Location = new System.Drawing.Point(12, 30);
            this.inPictureBox.Name = "inPictureBox";
            this.inPictureBox.Size = new System.Drawing.Size(640, 480);
            this.inPictureBox.TabIndex = 0;
            this.inPictureBox.TabStop = false;
            // 
            // outPictureBox
            // 
            this.outPictureBox.BackColor = System.Drawing.SystemColors.ActiveCaptionText;
            this.outPictureBox.Location = new System.Drawing.Point(658, 30);
            this.outPictureBox.Name = "outPictureBox";
            this.outPictureBox.Size = new System.Drawing.Size(640, 480);
            this.outPictureBox.TabIndex = 1;
            this.outPictureBox.TabStop = false;
            // 
            // btn_Load_IMG
            // 
            this.btn_Load_IMG.Location = new System.Drawing.Point(12, 516);
            this.btn_Load_IMG.Name = "btn_Load_IMG";
            this.btn_Load_IMG.Size = new System.Drawing.Size(132, 23);
            this.btn_Load_IMG.TabIndex = 2;
            this.btn_Load_IMG.Text = "Load New Image";
            this.btn_Load_IMG.UseVisualStyleBackColor = true;
            this.btn_Load_IMG.Click += new System.EventHandler(this.btn_Load_IMG_Click);
            // 
            // button3
            // 
            this.button3.Location = new System.Drawing.Point(150, 516);
            this.button3.Name = "button3";
            this.button3.Size = new System.Drawing.Size(130, 23);
            this.button3.TabIndex = 4;
            this.button3.Text = "Save As HEX";
            this.button3.UseVisualStyleBackColor = true;
            this.button3.Click += new System.EventHandler(this.button3_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(13, 7);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(85, 17);
            this.label1.TabIndex = 5;
            this.label1.Text = "Input Image:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(655, 7);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(97, 17);
            this.label2.TabIndex = 6;
            this.label2.Text = "Output Image:";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1314, 546);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.button3);
            this.Controls.Add(this.btn_Load_IMG);
            this.Controls.Add(this.outPictureBox);
            this.Controls.Add(this.inPictureBox);
            this.Name = "Form1";
            this.Text = "Nexsys 2 Palette Converter";
            ((System.ComponentModel.ISupportInitialize)(this.inPictureBox)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.outPictureBox)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.PictureBox inPictureBox;
        private System.Windows.Forms.PictureBox outPictureBox;
        private System.Windows.Forms.Button btn_Load_IMG;
        private System.Windows.Forms.Button button3;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
    }
}

