import React, {useEffect, useState} from 'react';
import { Medication, IFormData } from './App';
import { useVisibility } from '../providers/VisibilityProvider';
import {fetchNui} from "../utils/fetchNui";

interface FormProps {
    medList: Medication[] | null;
    prescript: IFormData | null;
    createDate: string;
    isReadOnly: boolean;
}

const Form = ({medList, prescript, createDate, isReadOnly}: FormProps) => {
    const { visible, setVisible } = useVisibility();
    const [formData, setFormData] = useState({
        patient: "", 
        medication: "",
        dosage: "",
        notes: "",
        signature: "",
    });
    
    const handleInputChange = (e:React.ChangeEvent<any>): void => {
        setFormData(prevData => {
            return {
                ...prevData,
                [e.target.name]: e.target.value
            }
        })
    }
    
    const handleReset = () => {
        setFormData({
            patient: "", 
            medication: "",
            dosage: "",
            notes: "",
            signature: "",
        })
    }

    const handleSubmit = () => {
        fetchNui<{success: boolean}>("submit", formData).then(data => {
            if (data.success) {
                handleReset();
            }
        });
    }

    useEffect(() => {
        if (!visible) {
            handleReset();
        }
    }, [visible])

    return (
        <form id="prescript-form">
            <div className="form-input">
                <label htmlFor="patient">Patient Name: </label>
                <input id="patient" type="text" onChange={handleInputChange} value={prescript?.patient || formData.patient} name="patient" readOnly={isReadOnly}/>
            </div>
            <div className="form-input">
                <label htmlFor="medication">Rx: </label>
                <select id="medication" onChange={handleInputChange} value={formData.medication} name="medication" disabled={isReadOnly}>
                    <option value="">{prescript?.medication || "Select Medication"}</option>
                    {medList && medList.map((option) => (
                        <option key={option.item} value={option.item}>{option.label}</option>
                    ))}
                </select>
            </div>
            <div className="form-input">
                <label htmlFor="doses">Dosages #: </label>
                <input id="doses" type="number" onChange={handleInputChange} value={prescript?.dosage || formData.dosage} name="dosage" disabled={isReadOnly}/>
            </div>

            <label htmlFor="notes">Additional Notes:</label>
            <br />
            <textarea id="notes" onChange={handleInputChange} value={prescript?.notes || formData.notes} name="notes" disabled={isReadOnly} />

            <div id="bottom-form">
                <div className="form-input signature-input">
                    <label htmlFor="sign">Signature: </label>
                    <input id="sign" type="text" onChange={handleInputChange} value={prescript?.signature || formData.signature} name="signature" disabled={isReadOnly} />
                </div>
                <div className="date">Date: {createDate}</div>
            </div>

            {isReadOnly || <button id="submit-button" type="button" onClick={handleSubmit} disabled={isReadOnly}>Submit</button>}
        </form>
    )
}

export default Form