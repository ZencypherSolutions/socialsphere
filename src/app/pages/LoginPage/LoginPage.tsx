import React from 'react';
import { LuWallet } from 'react-icons/lu';
import { Button } from '../../../components/ui/button';
import { Input } from '../../../components/ui/input';

const styles = {
  loginContainer: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '100vh',
    backgroundColor: '#f7f8fc',
    padding: '20px',
  },
  loginForm: {
    backgroundColor: '#ffffff',
    padding: '40px',
    borderRadius: '40px',
    boxShadow: '0 10px 20px rgba(0, 0, 0, 0.1)',
    width: '100%',
    maxWidth: '400px',
    fontFamily: 'Calibri, sans-serif',
  },
  header: {
    textAlign: 'center' as React.CSSProperties['textAlign'],
    fontSize: '32px',
    color: '#333',
    fontWeight: 'bold',
    textShadow: '2px 2px 4px rgba(0, 0, 0, 0.2)',
    fontFamily: 'Calibri, sans-serif',
  } as React.CSSProperties,
  info: { 
    textAlign: 'center' as React.CSSProperties['textAlign'], 
    color: '#555', 
    marginBottom: '20px', 
    fontFamily: 'Calibri, sans-serif'
  },
  formGroup: {
    marginBottom: '20px',
    fontFamily: 'Calibri, sans-serif',
  },
  label: {
    display: 'block',
    marginBottom: '8px',
    fontSize: '16px',
    color: '#555',
    textShadow: '2px 2px 4px rgba(0, 0, 0, 0.2)',
    fontFamily: 'Calibri, sans-serif',
  },
  input: {
    width: '100%',
    padding: '6px',
    border: '2px solid #ddd',
    borderRadius: '14px',
    fontSize: '16px',
    fontFamily: 'Calibri, sans-serif',
    textAlign: 'center' as React.CSSProperties['textAlign'],
  },
  button: {
    width: '100%',
    padding: '6px',
    backgroundColor: '#007bff',
    color: '#fff',
    border: 'none',
    cursor: 'pointer',
    fontSize: '18px',
    borderRadius: '14px',
    fontFamily: 'Calibri, sans-serif',
  },
  buttonHover: {
    backgroundColor: '#0056b3',
  },
};

const LoginPage = () => {
  return (
    <div style={styles.loginContainer}>
      <div style={styles.loginForm}>
        <h2 style={styles.header}>Sign In</h2>
        <p style={styles.info}>Please enter a username for your account and connect your wallet</p>
        <form>
            <div style={styles.formGroup}>
            <Input type="text" placeholder='Enter new username' id="username" name="username" required style={styles.input} />
            </div>
            <Button type="submit" style={styles.button}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <LuWallet style={{ marginRight: '8px' }} />
              Connect Wallet
              </div>
            </Button>
        </form>
      </div>
    </div>
  );
};


export default LoginPage;